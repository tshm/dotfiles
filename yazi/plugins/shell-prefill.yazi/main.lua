--- @sync entry
local function entry()
  local files = ""
  ya.dbg("hovered files:", cx.active.current.hovered)
  for _, url in pairs(cx.active.current.selected) do
    files = files .. " " .. ya.quote(tostring(url))
  end
  ya.notify("prefill files:", files)
  if files == "" then
    ya.notify({
      title = "Shell command",
      content = "No files selected",
      timeout = 5,
    })
    return
  end
  local value = ya.input({
    title = "Execute command:",
    position = { "top-center", w = 50, h = 3 },
    prefill = files:sub(2),
    cursor = 0,
  })
  if value then
    ya.emit("shell", { value, block = true })
  end
end

return { entry = entry }