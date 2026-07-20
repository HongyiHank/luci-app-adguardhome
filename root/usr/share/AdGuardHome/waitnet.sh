#!/bin/sh
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
count=0
while :; do
	for target in "1.1.1.1" "8.8.8.8" "www.google.com" "www.baidu.com"; do
		ping -c 1 -W 1 -q "$target" >/dev/null 2>&1 && {
			/etc/init.d/AdGuardHome force_reload
			exit 0
		}
	done
	count=$((count+1))
	[ $count -gt 18 ] && break
	sleep 5
done
/etc/init.d/AdGuardHome force_reload
exit 0
