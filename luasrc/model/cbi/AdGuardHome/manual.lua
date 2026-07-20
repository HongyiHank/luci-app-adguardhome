local m, s, o
local fs = require "nixio.fs"
local uci=require"luci.model.uci".cursor()
local sys=require"luci.sys"
local safe_path=require"luci.model.cbi.AdGuardHome.utils".safe_path
require("string")
require("io")
require("table")

m = Map("AdGuardHome")
local configpath = uci:get("AdGuardHome","AdGuardHome","configpath")
local binpath = uci:get("AdGuardHome","AdGuardHome","binpath")
if not safe_path(configpath) then configpath = nil end
if not safe_path(binpath) then binpath = "" end
s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true
s.addremove=false
--- config
o = s:option(TextValue, "escconf")
o.rows = 66
o.wrap = "off"
o.rmempty = true
o.cfgvalue = function(self, section)
	return fs.readfile("/tmp/AdGuardHometmpconfig.yaml")
		or (configpath and fs.readfile(configpath))
		or fs.readfile("/usr/share/AdGuardHome/AdGuardHome_template.yaml")
		or ""
end
o.validate=function(self, value)
	if not configpath then
		m.message = translate("Invalid config path")
		return nil
	end
	fs.writefile("/tmp/AdGuardHometmpconfig.yaml", value:gsub("\r\n", "\n"))
	if not binpath or binpath=="" or not fs.access(binpath) then
		m.message = translate("Core binary not found; configuration not validated or saved")
		return nil
	end
	-- run --check-config via ACL-allowed wrapper (custom binpath isn't whitelisted); wrapper writes log + rc
	sys.call("/usr/share/AdGuardHome/agh_check.sh /tmp/AdGuardHometmpconfig.yaml")
	local log = fs.readfile("/tmp/AdGuardHometest.log") or ""
	local rc = tonumber((fs.readfile("/tmp/AdGuardHometest.rc") or "1"):match("%d+")) or 1
	if rc == 0 and not log:match("%[error%]") then
		m.message = translate("Configuration validation passed")
		return value
	end
	m.message = translate("Configuration validation failed").." "..log
	return nil
end
o.write = function(self, section, value)
	if not configpath then return end
	if not fs.move("/tmp/AdGuardHometmpconfig.yaml", configpath) then
		m.message = translate("Failed to save config file (disk full or permission error)")
	end
end
o.remove = function(self, section, value)
	if not configpath then return end
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
