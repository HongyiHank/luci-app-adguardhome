local m, s, o
local fs = require "nixio.fs"
local uci=require"luci.model.uci".cursor()
local sys=require"luci.sys"
require("string")
require("io")
require("table")

m = Map("AdGuardHome")
local configpath = uci:get("AdGuardHome","AdGuardHome","configpath")
local binpath = uci:get("AdGuardHome","AdGuardHome","binpath")
if not (binpath and binpath:match("^/[%w/._%-]+$")) then binpath="" end
s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true
s.addremove=false
--- config
o = s:option(TextValue, "escconf")
o.rows = 66
o.wrap = "off"
o.rmempty = true
o.cfgvalue = function(self, section)
	return fs.readfile("/tmp/AdGuardHometmpconfig.yaml") or fs.readfile(configpath) or fs.readfile("/usr/share/AdGuardHome/AdGuardHome_template.yaml") or ""
end
o.validate=function(self, value)
	fs.writefile("/tmp/AdGuardHometmpconfig.yaml", value:gsub("\r\n", "\n"))
	if not fs.access(binpath) then
		m.message = translate("Core binary not found; configuration not validated or saved")
		return nil
	end
	sys.call(binpath.." -c /tmp/AdGuardHometmpconfig.yaml --check-config 2>&1 | grep '\\[error\\]' > /tmp/AdGuardHometest.log")
	local log = fs.readfile("/tmp/AdGuardHometest.log") or ""
	if log=="" then
		m.message = translate("Configuration validation passed")
		return value
	end
	m.message = translate("Configuration validation failed").." "..log
	return nil
end
o.write = function(self, section, value)
	fs.move("/tmp/AdGuardHometmpconfig.yaml",configpath)
end
o.remove = function(self, section, value)
	local tpl = fs.readfile("/usr/share/AdGuardHome/AdGuardHome_template.yaml") or ""
	fs.writefile(configpath, tpl)
	fs.remove("/tmp/AdGuardHometmpconfig.yaml")
end
--- js and reload button
o = s:option(DummyValue, "")
o.anonymous=true
o.template = "AdGuardHome/yamleditor"
if not fs.access(binpath) then
	o.description=translate("WARNING!!! No executable found, config will not be tested")
end
--- log
if (fs.access("/tmp/AdGuardHometmpconfig.yaml")) then
	local c=fs.readfile("/tmp/AdGuardHometest.log") or ""
	if (c~="") then
		m.message = translate("Configuration validation failed").." "..c
	end
end

return m
