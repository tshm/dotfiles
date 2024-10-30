const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const systemtray = await Service.import("systemtray");

const time = Variable("", {
  poll: [
    1000,
    function () {
      return Date().toString();
    },
  ],
});

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws.map(({ id }) =>
      Widget.Button({
        on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
        child: Widget.Label(`${id}`),
        class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
      }),
    ),
  );
  return Widget.Box({
    class_name: "workspaces",
    children: workspaces,
  });
}

// function SysTray() {
//   const items = systemtray.bind("items").as((items) =>
//
//   return Widget.Box({
//     class_name: "sys-tray",
//     children: systemtray.bind("widgets"),
//   });
// }

function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces()],
  });
}

const Bar = (/** @type {number} */ monitor = 0) =>
  Widget.Window({
    monitor,
    name: `bar${monitor}`,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Left(),
      end_widget: Widget.Label({
        hpack: "center",
        label: time.bind(),
      }),
    }),
  });

App.config({
  windows: [Bar()],
  // windows: [Bar(0)],
});
