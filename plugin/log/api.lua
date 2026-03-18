---@module "log.api"

---Public API for log.wz. All user-facing functions live here.
---`plugin/init.lua` requires this module after bootstrapping package.path.

local Log = require "log" ---@class Log
local config = require "log.config" ---@class Log.ConfigModule

---@class Log.API : Log
---@field setup   fun(overrides?: table) Override default config values.
---@field sinks   Log.Sinks              Lazy-loaded sink registry.
---@field levels  Log.Levels             Level constants and normalisation.
---@field config  Log.ConfigModule       Configuration module.
return setmetatable({
  setup = config.setup,
  sinks = require "log.sinks",
  levels = require "log.levels",
  config = config,
}, { __index = Log })
