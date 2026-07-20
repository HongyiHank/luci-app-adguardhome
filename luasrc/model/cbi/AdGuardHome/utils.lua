module("luci.model.cbi.AdGuardHome.utils", package.seeall)

-- same rules as init.d valid_path: [A-Za-z0-9/._-], no .., no //
function safe_path(p)
	return p and p:match("^/[%w/._%-]+$") and not p:match("%.%.") and not p:find("//", 1, true)
end
