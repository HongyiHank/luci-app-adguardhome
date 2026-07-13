#!/bin/sh
# ponytail: run --check-config for the configured binary under rpcd file ACL.
# Writes full output to /tmp/AdGuardHometest.log and the exit code to /tmp/AdGuardHometest.rc
# (both whitelisted temp paths) so LuCI can judge validity without exec'ing the custom binpath directly.
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
binpath=$(uci -q get AdGuardHome.AdGuardHome.binpath)
[ -z "$binpath" ] && binpath="/usr/bin/AdGuardHome/AdGuardHome"
cfg="$1"
"$binpath" -c "$cfg" --check-config > /tmp/AdGuardHometest.log 2>&1
echo $? > /tmp/AdGuardHometest.rc
