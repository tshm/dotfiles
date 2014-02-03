#!/bin/sh
LANG=
function update()
{
	str=`/sbin/ifconfig -s`
	BAT=$(acpi|sed 's/.*, \(.*\)%.*/\1/');
	acpi|grep 'Discharg' >/dev/null && COLOR="#ff0000" || COLOR="#00ff00"
	echo $str | grep -q 'eth0'  && e="E" || e=''
	echo $str | grep -q 'wlan0' && w="W" || w=''
	{ echo "lan.text = \"[$e$w]\"";
		[ -z $BAT ] || echo "batm:bar_data_add(\"val\", $BAT)";
		echo "batm:bar_properties_set(\"val\", {fg = \"$COLOR\"})";
	} | awesome-client
}
sleep 2;
while true; do update; sleep 30; done

#COL="#00ff00"
#echo $ACPI | grep 'Disch' && COL="#ffff00"
#echo "batm:bar_properties_set(\"val\", { fg = \"$COL\" })" | awesome-client
