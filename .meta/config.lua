---@meta Log.Config
error "cannot require a meta file!"

-- luacheck: push ignore 631 (line is too long)

---Plugin-local configuration for log.wz.
---
---@class Log.Config
---@field enabled          boolean        Whether logging is globally enabled.
---@field threshold        string|integer Minimum log level (e.g. `"WARN"` or `2`).
---@field sinks            Log.Config.Sinks Sink-related settings.

---@class Log.Config.Sinks
---@field default_enabled boolean Prepend the default WezTerm sink to every logger.

---Configuration access and mutation.
---
---@class Log.ConfigModule
---@field get   fun(): Log.Config             Return the current configuration.
---@field setup fun(overrides?: table): nil    Merge partial overrides into the config.

-- luacheck: pop
