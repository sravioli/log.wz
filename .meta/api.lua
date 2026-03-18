---@meta Log.API
error "cannot require a meta file!"

-- luacheck: push ignore 631 (line is too long)

---Public API surface returned by the log.wz plugin.
---
---Inherits all methods from `Log` (`:new`, `:log`, `:debug`, `:info`, `:warn`, `:error`,
---`:add_sink`) and exposes additional top-level fields for configuration and sub-modules.
---
---@class Log.API : Log
---@field setup   fun(overrides?: table) Override default config values.
---@field sinks   Log.Sinks              Lazy-loaded sink registry.
---@field levels  Log.Levels             Level constants and normalisation.
---@field config  Log.ConfigModule       Configuration module.

-- luacheck: pop
