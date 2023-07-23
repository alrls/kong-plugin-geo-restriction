local lrucache = require "resty.lrucache"
local kong_meta = require "kong.meta"

local geoip_module = require 'geoip'
local geoip_country = require 'geoip.country'
local geoip_country_filename = '/usr/share/GeoIP/GeoIP.dat'

local kong = kong
local log = kong.log
local ngx_var = ngx.var

local IPMATCHER_COUNT = 512
local IPMATCHER_TTL = 3600
local cache = lrucache.new(IPMATCHER_COUNT)

local GeoRestrictionHandler = {PRIORITY = 991, VERSION = kong_meta.version}

local isempty
do
  local tb_isempty = require "table.isempty"

  isempty = function(t) return t == nil or tb_isempty(t) end
end

local function do_exit(status, message)
  status = status or 403
  message = message or
                string.format("Country is not allowed, IP: %s",
                              ngx_var.remote_addr)

  log.warn(message)

  return kong.response.error(status, message)
end

local function match_geo(countries, current_country)
  for i, v in ipairs(countries) do
    if v == current_country then return true end
  end
  return false
end

local function do_restrict(conf)
  -- local current_ip = ngx.var.remote_addr;
  local current_ip = ngx.req.get_headers()['X-Forwarded-For']
  local current_country =
      geoip_country.open(geoip_country_filename):query_by_addr(current_ip).code

  if not current_country then
    return do_exit(403, "Cannot identify the client country")
  end

  local deny_countries = conf.deny
  if not isempty(deny_countries) then
    local blocked = match_geo(deny_countries, current_country)
    if blocked then return do_exit(conf.status, conf.message) end
  end

  local allow_countries = conf.allow
  if not isempty(allow_countries) then
    local allowed = match_geo(allow_countries, current_country)
    if not allowed then return do_exit(conf.status, conf.message) end
  end
end

function GeoRestrictionHandler:access(conf) return do_restrict(conf) end

function GeoRestrictionHandler:preread(conf) return do_restrict(conf) end

return GeoRestrictionHandler
