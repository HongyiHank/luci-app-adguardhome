#!/bin/sh
# ponytail: wrapper so LuCI can exec the (possibly custom-path) AdGuardHome binary under rpcd file ACL,
# which only whitelists this script path, not the user-configured binpath.
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
binpath=$(uci -q get AdGuardHome.AdGuardHome.binpath)
[ -z "$binpath" ] && binpath="/usr/bin/AdGuardHome/AdGuardHome"
[ -x "$binpath" ] || exit 127
exec "$binpath" --version
