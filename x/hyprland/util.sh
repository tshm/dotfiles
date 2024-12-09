#!/bin/sh
options=()

warp-cli status | grep Connected &&
  warpcmd="✅ Warp Disconnect: warp-cli disconnect; warp-cli status" ||
  warpcmd="❌ Warp Connect: warp-cli connect; warp-cli status"
options+=("$warpcmd")

btdevice=$(bluetoothctl devices Connected)
[ -n "$btdevice" ] && {
  addr=$(echo $btdevice | cut -d' ' -f2)
  name=$(echo $btdevice | cut -d' ' -f3-)
  btcmd="📶 Reconnect BluetoothDevice $name: bluetoothctl disconnect $addr; bluetoothctl connect $addr"
  options+=("$btcmd")
}
echo $btcmd

# Define the menu options
options+=(
  "💤 Sleep: systemctl suspend"
  "⏻  Shutdown: systemctl poweroff"
  "🔄 Reboot: systemctl reboot"
)

# Display the options using Rofi
selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Select an action:")

# Execute the selected command
if [[ -n "$selected" ]]; then
  cmd=$(echo $selected | cut -d: -f2- | xargs)
  result=$(eval $cmd)
  [ "$?" = "0" ] && icon=✅ || icon=❌ 
  notify-send "$icon" "$result"
fi

