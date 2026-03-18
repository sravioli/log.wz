---@module "log"

local cfg = require "log.config" ---@class Log.ConfigModule

-- selene: allow(incorrect_standard_library_use)
local unpack = unpack or table.unpack
local l = require "log.levels" ---@class Log.Levels

local default_sink = require "log.sinks.wz"

---Convert a value into a printable string.
---
---`userdata` values are converted using `tostring`, while all other types are
---pretty-printed using `wezterm.inspect` when available, falling back to `tostring`.
---
---@param v any Value to stringify.
---@return string
local function stringify(v)
  if type(v) == "userdata" then
    return tostring(v)
  end
  local ok, wz = pcall(require, "wezterm")
  if ok and type(wz) == "table" and wz.to_string then
    return wz.to_string(v)
  end
  return tostring(v)
end

---Convert all vararg values into printable strings.
---
---`userdata` values are converted using `tostring`, while all other types are
---pretty-printed when possible. The returned values can be safely passed to
---`string.format`.
---
---@param ... any Values to stringify.
---@return ... Stringified values.
local function prettify_args(...)
  local args = { ... }
  for i = 1, #args do
    args[i] = stringify(args[i])
  end
  return unpack(args)
end

---@class Log
local M = {}
M.__index = M

---Create new logger instance.
---
---If `config.sinks.default_enabled` is true, the default sink is prepended to the list.
---
---@param tag?     string        Identifier printed in brackets before message. Defaults to "Log".
---@param enabled? boolean       Enable logging status. Defaults to config or true.
---@param sinks?   Log.Sink[] List of sinks to output to.
---@return Log
function M:new(tag, enabled, sinks)
  local c = cfg.get()
  sinks = sinks or {}

  if c.sinks.default_enabled then
    table.insert(sinks, 1, default_sink)
  end

  return setmetatable({
    tag = tag or "Log",
    enabled = c.enabled or enabled or true,
    threshold = l.normalize(c.threshold or l.levels.WARN),
    sinks = sinks,
  }, self)
end

---Add sink to the sinks table.
---
---@param sink Log.Sink Function to handle log entry.
function M:add_sink(sink)
  table.insert(self.sinks, sink)
end

---Emit event to all sinks.
---
---@param event Log.Event Data structure containing log details.
---@private
function M:_emit(event)
  for _, sink in ipairs(self.sinks) do
    sink(event)
  end
end

---Log message with specified log level.
---
---Accepts simple string or format string. Non-string arguments are stringified
---(userdata via `tostring`, others via pretty-printing when available).
---
---@param level   Log.Level Severity level.
---@param message string       Log message or format string.
---@param ...     any          Additional arguments to format into message.
function M:log(level, message, ...)
  local lvl = l.normalize(level)
  if not (cfg.get().enabled and self.enabled) or lvl < self.threshold then
    return
  end

  local msg = ("[%s] %s"):format(self.tag, message:format(prettify_args(...)))

  self:_emit {
    level = lvl,
    level_name = l.names[lvl],
    tag = self.tag,
    message = msg,
    raw_message = message,
  }
end

---Log debug level message.
---
---Prepends "DEBUG: " to the message string.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function M:debug(message, ...)
  self:log(l.levels.DEBUG, "DEBUG: " .. message, ...)
end

---Log information level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function M:info(message, ...)
  self:log(l.levels.INFO, message, ...)
end

---Log warning level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function M:warn(message, ...)
  self:log(l.levels.WARN, message, ...)
end

---Log error level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function M:error(message, ...)
  self:log(l.levels.ERROR, message, ...)
end

return M
