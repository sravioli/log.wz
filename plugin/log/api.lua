---@module "log.api"

---Public API for log.wz. All user-facing functions live here.
---`plugin/init.lua` requires this module after bootstrapping package.path.

local cfg = require "log.config" ---@class Log.ConfigModule
local wezterm = require "wezterm"

-- selene: allow(incorrect_standard_library_use)
local unpack = table.unpack
local l = require "log.levels" ---@class Log.Levels

local default_sink = require "log.sinks.wz"

---@class Log.Event
---@field timestamp   integer Unix timestamp in seconds.
---@field datetime    string  Local timestamp formatted as `%Y-%m-%d %H:%M:%S%.3f`.
---@field level       integer Log severity level.
---@field level_name  string  Human-readable name of the log level.
---@field tag         string  Identifier of the logger instance.
---@field message     string  Final formatted log message.
---@field raw_message string  Original message string before formatting.

---@alias Log.Sink fun(entry: Log.Event): any|nil

---@alias Log.Level Log.Levels.Level|string|integer

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
  if wezterm.to_string then
    return wezterm.to_string(v)
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

---Build consistent timestamp fields for a log event.
---@return integer timestamp
---@return string datetime
local function make_timestamp()
  if wezterm.time and wezterm.time.now then
    local now = wezterm.time.now()
    local timestamp = tonumber(now:format "%s") or os.time()
    return timestamp, now:format "%Y-%m-%d %H:%M:%S%.3f"
  end

  local timestamp = os.time()
  return timestamp, tostring(os.date("%Y-%m-%d %H:%M:%S", timestamp))
end

---A lightweight wrapper around WezTerm logging facilities.
---
---Logging is globally gated by `Log.Config.enabled`. When set to `false`, all
---logger instances are silenced.
---@class Log
---@field tag       string     Printable name prefix included in each log line.
---@field enabled   boolean    Whether this logger instance is currently enabled.
---@field threshold integer    Minimum level required for logs to be emitted.
---@field sinks     Log.Sink[] List of active sinks.
local Log = {}
Log.__index = Log

---Create new logger instance.
---
---If `config.sinks.default_enabled` is true, the default sink is prepended to the list.
---
---@param tag?     string        Identifier printed in brackets before message. Defaults to "Log".
---@param enabled? boolean       Enable logging status. Defaults to config or true.
---@param sinks?   Log.Sink[] List of sinks to output to.
---@return Log
function Log:new(tag, enabled, sinks)
  local c = cfg.get()
  sinks = sinks or {}
  local _ = self

  if c.sinks.default_enabled then
    table.insert(sinks, 1, default_sink)
  end

  return setmetatable({
    tag = tag or "Log",
    enabled = c.enabled or enabled or true,
    threshold = l.normalize(c.threshold or l.levels.WARN),
    sinks = sinks,
  }, Log)
end

---Add sink to the sinks table.
---
---@param sink Log.Sink Function to handle log entry.
function Log:add_sink(sink)
  table.insert(self.sinks, sink)
end

---Emit event to all sinks.
---
---@param event Log.Event Data structure containing log details.
---@private
function Log:_emit(event)
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
function Log:log(level, message, ...)
  local lvl = l.normalize(level)
  if not (cfg.get().enabled and self.enabled) or lvl < self.threshold then
    return
  end

  local msg = ("[%s] %s"):format(self.tag, message:format(prettify_args(...)))
  local timestamp, datetime = make_timestamp()

  self:_emit {
    timestamp = timestamp,
    datetime = datetime,
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
function Log:debug(message, ...)
  self:log(l.levels.DEBUG, "DEBUG: " .. message, ...)
end

---Log information level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function Log:info(message, ...)
  self:log(l.levels.INFO, message, ...)
end

---Log warning level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function Log:warn(message, ...)
  self:log(l.levels.WARN, message, ...)
end

---Log error level message.
---
---@param message string Log message or format string.
---@param ...     any    Additional arguments to format into message.
function Log:error(message, ...)
  self:log(l.levels.ERROR, message, ...)
end

---@class Log.API : Log
---@field setup   fun(overrides?: table) Override default config values.
---@field sinks   Log.Sinks              Lazy-loaded sink registry.
---@field levels  Log.Levels             Level constants and normalisation.
---@field config  Log.ConfigModule       Configuration module.
return setmetatable({
  setup = cfg.setup,
  sinks = require "log.sinks",
  levels = l,
  config = cfg,
}, { __index = Log })
