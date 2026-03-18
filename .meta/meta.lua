---@meta Log
error "cannot require a meta file!"

---@class Log.Event
---@field public level       integer Log severity level.
---@field public level_name  string  Human-readable name of the log level.
---@field public tag         string  Identifier of the logger instance.
---@field public message     string  Final formatted log message.
---@field public raw_message string  Original message string before formatting.

---@alias Log.Sink fun(entry: Log.Event): any|nil

---@alias Log.Level Log.Levels.Level|string|integer

---@class Log
---@field tag       string        Printable name prefix included in each log line.
---@field enabled   boolean       Whether this logger instance is currently enabled.
---@field threshold integer       Minimum level required for logs to be emitted.
---@field sinks     Log.Sink[] List of active sinks.
---
---A lightweight wrapper around WezTerm’s built-in logging facilities.
---
---Logging is globally gated by the `Log.Config.enabled` variable. When set to `false`
---(either via `setup()` or at runtime), **all logger instances are silenced**.
---
---Logging is **enabled** by default.
---@see Log.Config to see the default global logger options
