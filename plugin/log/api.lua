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
---pretty-printed using `wezterm.to_string` when available, falling back to `tostring`.
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
---pretty-printed when possible. Uses `select` to preserve trailing `nil`
---arguments so that `string.format` receives the correct argument count.
---
---@param ... any Values to stringify.
---@return ... Stringified values.
local function prettify_args(...)
  local n = select("#", ...)
  local args = { ... }
  for i = 1, n do
    args[i] = stringify(args[i])
  end
  return unpack(args, 1, n)
end

---Build consistent timestamp fields for a log event.
---@return integer timestamp
---@return string|osdate datetime
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
---The provided `sinks` array is shallow-copied and never mutated.
---
---@param tag?     string        Identifier printed in brackets before message. Defaults to "Log".
---@param enabled? boolean       Enable logging status. Defaults to true.
---@param sinks?   Log.Sink[] List of sinks to output to.
---@return Log
function Log.new(tag, enabled, sinks)
  local c = cfg.get()
  local new_sinks = {}

  if c.sinks.default_enabled then
    new_sinks[1] = default_sink
  end

  if sinks then
    for i = 1, #sinks do
      new_sinks[#new_sinks + 1] = sinks[i]
    end
  end

  if enabled == nil then
    enabled = true
  end

  return setmetatable({
    tag = tag or "Log",
    enabled = enabled,
    threshold = l.normalize(c.threshold) or l.levels.WARN,
    sinks = new_sinks,
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
---Each sink is called inside `pcall` so that a failing sink cannot prevent
---subsequent sinks from running or crash the caller.
---
---@param event Log.Event Data structure containing log details.
---@private
function Log:_emit(event)
  for _, sink in ipairs(self.sinks) do
    local ok, err = pcall(sink, event)
    if not ok then
      wezterm.log_error(("[Log] Sink error: %s"):format(tostring(err)))
    end
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
  if not lvl or not (cfg.get().enabled and self.enabled) or lvl < self.threshold then
    return
  end

  local ok_fmt, formatted = pcall(string.format, message, prettify_args(...))
  local msg = ("[%s] %s"):format(self.tag, ok_fmt and formatted or message)
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
  ---Support both `log.setup(opts)` and `log:setup(opts)` call styles.
  setup = function(self_or_overrides, overrides)
    if overrides ~= nil then
      cfg.setup(overrides)
    else
      cfg.setup(self_or_overrides)
    end
  end,
  sinks = require "log.sinks",
  levels = l,
  config = cfg,
}, { __index = Log })
