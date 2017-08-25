#!/bin/bash

BAT_PATH=/sys/class/power_supply/BAT0
AC_PATH=/sys/class/power_supply/AC
delim=" "

clock() {
	dt=$(date "+%a %b %d %T")
	echo $dt
}

vol() {
	status=$(pulseaudio-ctl full-status)
	vol=$(echo $status | cut -d' ' -f1)
	muted=$(echo $status | cut -d' ' -f2)
	if [[ "$muted" == "yes" ]]; then
		echo "\ue04f$vol"
	else
		echo "\ue04e$vol"
	fi
}

bat() {
	energy_full=`cat $BAT_PATH/energy_full`
	energy_now=`cat $BAT_PATH/energy_now`
	percent=$((100 * $energy_now / $energy_full))
	status=`cat $BAT_PATH/status`
	ac_status=`cat $AC_PATH/online`

	if [[ $ac_status -eq 1 ]]; then
		icon="\ue23a"
	else
		if [[ $percent -lt 10 ]]; then
			icon="\ue236"
		elif [[ $percent -gt 90 ]]; then
			icon="\ue238"
		else 
			icon="\ue237"
		fi
	fi	
	

	echo "$icon$percent"
}

kb() {
	xkblayout-state print %s
}

song() {
	st=$(mpc status)
	if [[ $st == "volume: n/a"* ]]; then
		icon="\ue099"
		song='stopped'
	else
		status=`echo $st | sed 's/^\(.*\)\s\[\(.*\)\].*$/\2/g'`
		if [[ $status == 'playing' ]]; then
			icon="\ue09a"
		else
			icon="\ue09b"
		fi
		#song=`echo $st | sed 's/^\(.*\)\s\[\(.*\)\].*$/\1/g'`
		song=`mpc current`
	fi
	echo $icon$song
}

space() {
	free=`df -h | grep /dev/sda2 | awk '{print $4}'`
	echo $free
}

mem() {
	#todo
	meminfo=`cat /proc/meminfo`
	free=`echo $meminfo | grep MemFree | awk '{ print $2 }'`
	echo $free
}

cpu() {
	#todo
	echo cpu
}

temp() {
	#todo
	echo temp
}

while true; do
	echo -ne "$(kb) $delim $(space) $delim $(bat) $delim $(song) $delim $(vol) $delim $(clock)"
        sleep 1
done
