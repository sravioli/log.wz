---@module "log.sinks.file"

local wezterm = require "wezterm"

local json_mod

---@return Log.Sinks.Json? json
---@return string? err
local function get_json_module()
  if json_mod then
    return json_mod
  end
  local ok, mod = pcall(require, "log.sinks.json")
  if not ok then
    return nil, tostring(mod)
  end
  json_mod = mod
  return json_mod
end

---@alias Log.Sinks.FileFormat "json"|"text"
---@alias Log.Sinks.FileFormatter fun(event: Log.Event): string

---@class Log.Sinks.FileOptions
---@field format? Log.Sinks.FileFormat Output format. Defaults to "json".
---@field formatter? Log.Sinks.FileFormatter Custom formatter. When provided, it overrides `format`.

---@class Log.Sinks.FileSink
---@field path string Destination file path.
---@field format Log.Sinks.FileFormat Output format for written entries.
---@field formatter? Log.Sinks.FileFormatter Custom formatter used for serialization.
local M = {}
M.__index = M

---Check whether a path resides inside `wezterm.config_dir`.
---Writing log files there triggers an infinite config-reload loop because
---WezTerm watches the entire config directory for changes.
---@param path string Destination file path.
---@return boolean
local function is_inside_config_dir(path)
  local dir = wezterm.config_dir
  if not dir then
    return false
  end
  -- normalize separators to forward slashes for comparison
  local norm_path = path:gsub("\\", "/"):lower()
  local norm_dir = dir:gsub("\\", "/"):lower()
  if norm_dir:sub(-1) ~= "/" then
    norm_dir = norm_dir .. "/"
  end
  return norm_path:sub(1, #norm_dir) == norm_dir
end

---Create a file sink that appends log events as JSON Lines.
---
---**Warning:** the destination path must NOT be inside `wezterm.config_dir`
---or every write will trigger a config reload loop and freeze WezTerm.
---
---@param path string Destination file path.
---@param opts? Log.Sinks.FileOptions
---@return Log.Sinks.FileSink
function M.new(path, opts)
  opts = opts or {}

  if is_inside_config_dir(path) then
    wezterm.log_error(
      "[Log.File] log path is inside wezterm.config_dir — this causes an "
        .. "infinite config-reload loop. Move the file outside: "
        .. wezterm.config_dir
    )
  end

  return setmetatable({
    path = path,
    format = opts.format or "json",
    formatter = opts.formatter,
  }, M)
end

---Serialize an event to the configured file format.
---@param event Log.Event
---@return boolean ok
---@return string payload_or_err
function M:serialize(event)
  if self.formatter then
    local ok_format, payload = pcall(self.formatter, event)
    if not ok_format then
      return false, tostring(payload)
    end
    if type(payload) ~= "string" then
      return false, "formatter must return a string"
    end
    return true, payload
  end

  if self.format == "text" then
    return true, ("%s [%s] %s"):format(event.datetime, event.level_name, event.message)
  end

  local json, err = get_json_module()
  if not json then
    return false, ("unable to load json sink: %s"):format(tostring(err))
  end

  local ok_encode, payload = pcall(json.encode, event)
  if not ok_encode then
    return false, tostring(payload)
  end

  return true, payload
end

---Append raw text to the sink file.
---@param payload string
---@return boolean ok
---@return string? err
function M:append(payload)
  local handle, err = io.open(self.path, "a")
  if not handle then
    return false, err
  end

  local ok_write, write_err = handle:write(payload, "\n")
  local ok_close, close_err = handle:close()
  if not ok_write then
    return false, write_err
  end
  if not ok_close then
    return false, close_err
  end

  return true
end

---Encode and append an event as a formatted line.
---@param event Log.Event
---@return nil
function M:write(event)
  local ok_serialize, payload = self:serialize(event)
  if not ok_serialize then
    wezterm.log_error(
      ("[Log.File] Failed to serialize event: %s"):format(tostring(payload))
    )
    return
  end

  local ok_append, err = self:append(payload)
  if not ok_append then
    wezterm.log_error(
      ("[Log.File] Failed to append to %s: %s"):format(self.path, tostring(err))
    )
  end
end

---Return a sink function compatible with Log.
---@return Log.Sink
function M:sink()
  return function(event)
    self:write(event)
  end
end

return M
