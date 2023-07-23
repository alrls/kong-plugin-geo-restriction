# Installation
http://luarocks.org/modules/newage/kong-plugin-geo-restriction

`luarocks install kong-plugin-geo-restriction`

```
custom_plugins = geo-restriction
```

`Reminder: don't forget to update the custom_plugins directive for each node in your Kong cluster.`

# API

POST :8001/plugins
```
{
	"name": "geo-restriction",
	"config.blacklist_countries": ["UA", "UK"],
	"config.whitelist_ips": ["37.73.161.34"]
}
```
