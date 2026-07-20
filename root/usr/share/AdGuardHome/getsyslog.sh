#!/bin/sh
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
logread -e AdGuardHome > /tmp/AdGuardHome.log
logread -e AdGuardHome -f >> /tmp/AdGuardHome.log &
pid=$!
echo "1">/var/run/AdG_syslog
misses=0
while true
do
	sleep 3
	watchdog=$(cat /var/run/AdG_syslog)
	if [ "$watchdog"x == "0"x ]; then
		misses=$((misses+1))
		if [ $misses -ge 4 ]; then
			kill $pid 2>/dev/null
			rm -f /tmp/AdGuardHome.log
			rm -f /var/run/AdG_syslog
			exit 0
		fi
	else
		misses=0
		echo "0">/var/run/AdG_syslog
	fi
done
