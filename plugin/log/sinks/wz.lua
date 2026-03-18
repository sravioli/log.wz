---@module "log.sinks.wz"

---@diagnostic disable: undefined-field

local wz = require "wezterm" ---@class Wezterm
local levels = require("log.levels").levels

---Log events to WezTerm's native logging facility.
---
---Map internal log levels (DEBUG, INFO, WARN, ERROR) to their corresponding
---`wezterm.log_*` functions.
---
---@param event Log.Event
return function(event)
  if event.level == levels.DEBUG or event.level == levels.INFO then
    wz.log_info(event.message)
  elseif event.level == levels.WARN then
    wz.log_warn(event.message)
  elseif event.level == levels.ERROR then
    wz.log_error(event.message)
  end
end
