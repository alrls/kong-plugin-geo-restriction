local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "geo-restriction"

return {
  name = PLUGIN_NAME,
  fields = {
    {
      protocols = typedefs.protocols {
        default = {"http", "https", "tcp", "tls", "grpc", "grpcs"}
      }
    }, {
      config = {
        type = "record",
        fields = {
          {
            allow = {
              -- description = "List of countries to allow. One of `config.whitelist_countries` or `config.blacklist_countries` must be specified.",
              type = "set",
              elements = {type = "string"}
            }
          }, {
            deny = {
              -- description = "List of countries to deny. One of `config.whitelist_countries` or `config.blacklist_countries` must be specified.",
              type = "set",
              elements = {type = "string"}
            }
          }, {
            status = {
              -- description = "The HTTP status of the requests that will be rejected by the plugin.",
              type = "number",
              required = false
            }
          }, {
            message = {
              -- description = "The message to send as a response body to rejected requests.",
              type = "string",
              required = false
            }
          }
        }
      }
    }
  },
  entity_checks = {{at_least_one_of = {"config.allow", "config.deny"}}}
}
