/* Compile against the patched driver; substitute only the proprietary matcher.
 * No USB access or biometric data required. */
#define ft_engine_accept test_engine_accept
#define ft_engine_verify test_engine_verify
#include "libfprint/drivers/ft9201.c"

static guint8 matching_template;
static gboolean probe_ready;
static gboolean reject_frame;

uint32_t
test_engine_accept (const uint8_t *image, int width, int height, uint8_t purpose)
{
  g_assert_cmpint (purpose, ==, 1);
  probe_ready = TRUE;
  return reject_frame ? 1 : 0;
}

int
test_engine_verify (const uint8_t *blob, size_t len)
{
  g_assert_true (probe_ready);
  probe_ready = FALSE; /* A matcher may consume the extracted probe. */
  return len == 1 && blob[0] == matching_template;
}

static FpPrint *
make_print (guint8 value)
{
  FpPrint *print = g_object_new (FP_TYPE_PRINT,
                               "driver", "ft9201", "device-id", "test", NULL);
  GVariant *arr = g_variant_new_fixed_array (G_VARIANT_TYPE_BYTE, &value, 1, 1);
  g_object_set (print, "fpi-data", g_variant_new ("(@ay)", arr), NULL);
  return print;
}

int
main (void)
{
  FpiDeviceFt9201 self = { .sensor_width = 64, .sensor_height = 80 };
  g_autoptr(GPtrArray) gallery = g_ptr_array_new_with_free_func (g_object_unref);
  g_autoptr(GError) error = NULL;
  FpPrint *left = make_print (1);
  FpPrint *right = make_print (2);
  g_ptr_array_add (gallery, left);
  g_ptr_array_add (gallery, right);

  matching_template = 2;
  g_assert_true (identify_match (&self, gallery, &error) == right);
  g_assert_no_error (error);
  matching_template = 1;
  g_assert_true (identify_match (&self, gallery, &error) == left);
  g_assert_no_error (error);
  matching_template = 3;
  g_assert_null (identify_match (&self, gallery, &error));
  g_assert_no_error (error);

  reject_frame = TRUE;
  g_assert_null (identify_match (&self, gallery, &error));
  g_assert_error (error, FP_DEVICE_RETRY, FP_DEVICE_RETRY_CENTER_FINGER);
  g_clear_error (&error);
  reject_frame = FALSE;

  g_object_set (left, "fpi-data", g_variant_new_string ("invalid"), NULL);
  g_assert_null (identify_match (&self, gallery, &error));
  g_assert_error (error, FP_DEVICE_ERROR, FP_DEVICE_ERROR_DATA_INVALID);
  g_clear_error (&error);
  g_object_set (left, "fpi-data", g_variant_new ("(@ay)",
    g_variant_new_fixed_array (G_VARIANT_TYPE_BYTE, NULL, 0, 1)), NULL);
  g_assert_null (identify_match (&self, gallery, &error));
  g_assert_error (error, FP_DEVICE_ERROR, FP_DEVICE_ERROR_DATA_INVALID);
  g_print ("FT9201 gallery matching: passed\n");
  return 0;
}
