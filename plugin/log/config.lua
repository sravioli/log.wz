---@module "log.config"

---@class Log.Config
---@field enabled          boolean Whether logging is globally enabled.
---@field threshold        string|integer  Minimum log level.
---@field sinks            Log.Config.Sinks Sink-related settings.

---@class Log.Config.Sinks
---@field default_enabled boolean Prepend the default WezTerm sink to every logger.

---@type Log.Config
local _config = {
  enabled = true,
  threshold = "WARN",
  sinks = { default_enabled = true },
}

---@class Log.ConfigModule
local M = {}

---Return the current configuration (read-only reference).
---
---@return Log.Config
function M.get()
  return _config
end

---Override configuration values.
---
---Only keys present in the defaults are accepted; unknown keys are silently
---ignored.  The `sinks` sub-table is merged one level deep.
---
---@param overrides? table Partial config to merge.
function M.setup(overrides)
  if type(overrides) ~= "table" then
    return
  end

  if overrides.enabled ~= nil then
    _config.enabled = overrides.enabled
  end
  if overrides.threshold ~= nil then
    _config.threshold = overrides.threshold
  end
  if type(overrides.sinks) == "table" then
    if overrides.sinks.default_enabled ~= nil then
      _config.sinks.default_enabled = overrides.sinks.default_enabled
    end
  end
end

return M
