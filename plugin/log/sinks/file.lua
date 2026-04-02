---@module "log.sinks.file"

local wezterm = require "wezterm"

-- selene: allow(incorrect_standard_library_use)
local sep = package.config:sub(1, 1)

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

---Return a platform-appropriate directory for log files.
---@return string
local function default_log_dir()
  if sep == "\\" then
    local dir = os.getenv "LOCALAPPDATA" or os.getenv "APPDATA"
    if dir then
      return dir .. "\\wezterm"
    end
  else
    local xdg = os.getenv "XDG_DATA_HOME"
    if xdg then
      return xdg .. "/wezterm"
    end
    local home = os.getenv "HOME"
    if home then
      return home .. "/.local/share/wezterm"
    end
  end
  return "."
end

---Create a directory (and parents) if it doesn't already exist.
---
---Uses `mkdir` which is a no-op when the directory already exists.
---@param dir string
local function ensure_dir(dir)
  if sep == "\\" then
    os.execute(('mkdir "%s" 2>nul'):format(dir))
  else
    os.execute(("mkdir -p '%s' 2>/dev/null"):format(dir))
  end
end

---Normalize a path to forward-slashed lowercase for comparison.
---@param path string
---@return string
local function norm(path)
  return path:gsub("\\", "/"):lower()
end

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
  local norm_dir = norm(dir)
  if norm_dir:sub(-1) ~= "/" then
    norm_dir = norm_dir .. "/"
  end
  return norm(path):sub(1, #norm_dir) == norm_dir
end

---Extract the filename component from a path.
---@param path string
---@return string
local function basename(path)
  return path:match "([^/\\]+)$" or path
end

---Resolve a safe log-file path.
---
---When `path` is nil a default is chosen.  When `path` falls inside
---`wezterm.config_dir` the file is relocated to the default log directory
---and a warning is emitted.
---
---@param path? string Requested file path.
---@return string path  Safe, resolved path.
local function resolve_path(path)
  local log_dir = default_log_dir()

  if not path then
    ensure_dir(log_dir)
    return log_dir .. sep .. "log.wz.log"
  end

  if is_inside_config_dir(path) then
    local name = basename(path)
    local safe = log_dir .. sep .. name
    wezterm.log_warn(
      (
        "[Log.File] '%s' is inside wezterm.config_dir — relocated to '%s' "
        .. "to avoid an infinite config-reload loop"
      ):format(path, safe)
    )
    ensure_dir(log_dir)
    return safe
  end

  return path
end

---@alias Log.Sinks.FileFormat "json"|"text"
---@alias Log.Sinks.FileFormatter fun(event: Log.Event): string

---@class Log.Sinks.FileOpts
---@field path? string Destination file path. Auto-resolved when omitted.
---@field format? Log.Sinks.FileFormat Output format. Defaults to "json".
---@field formatter? Log.Sinks.FileFormatter Custom formatter. When provided, it overrides `format`.

---@class Log.Sinks.FileSink
---@field path string Resolved destination file path.
---@field format Log.Sinks.FileFormat Output format for written entries.
---@field formatter? Log.Sinks.FileFormatter Custom formatter used for serialization.
local FileSink = {}
FileSink.__index = FileSink

---Dispatch to write when used as a sink function.
---@param event Log.Event
function FileSink:__call(event)
  self:write(event)
end

---Serialize an event to the configured file format.
---@param event Log.Event
---@return boolean ok
---@return string payload_or_err
function FileSink:serialize(event)
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
function FileSink:append(payload)
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
function FileSink:write(event)
  local ok_serialize, payload = self:serialize(event)
  if not ok_serialize then
    wezterm.log_error(("[Log.File] Failed to serialize event: %s"):format(tostring(payload)))
    return
  end

  local ok_append, err = self:append(payload)
  if not ok_append then
    wezterm.log_error(("[Log.File] Failed to append to %s: %s"):format(self.path, tostring(err)))
  end
end

---Create a new file sink.
---
---The returned instance is callable and can be passed directly to `Log:new`'s
---sinks array. When `opts.path` is omitted a platform-appropriate default is
---chosen. Paths inside `wezterm.config_dir` are automatically relocated.
---
---@param opts? Log.Sinks.FileOpts
---@return Log.Sinks.FileSink
return setmetatable({}, {
  __call = function(_, opts)
    opts = opts or {}
    return setmetatable({
      path = resolve_path(opts.path),
      format = opts.format or "json",
      formatter = opts.formatter,
    }, FileSink)
  end,
})
