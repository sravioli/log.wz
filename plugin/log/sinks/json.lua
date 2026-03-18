---@module "log.sinks.json"

local wezterm = require "wezterm"
local serde = wezterm.serde

---@class Log.Sinks.Json
local M = {}

---Encode a Lua value to a JSON string.
---@param value any
---@return string
function M.encode(value)
  if not serde or not serde.json_encode then
    error "wezterm.serde.json_encode is not available"
  end
  return serde.json_encode(value)
end

---Decode a JSON string back to a Lua value.
---@param payload string
---@return any
function M.decode(payload)
  if not serde or not serde.json_decode then
    error "wezterm.serde.json_decode is not available"
  end
  return serde.json_decode(payload)
end

---Emit an event as a single JSON line through WezTerm's logger.
---@param event Log.Event
---@return nil
function M.write(event)
  local ok_encode, payload = pcall(M.encode, event)
  if not ok_encode then
    wezterm.log_error(("[Log.JSON] Failed to encode event: %s"):format(tostring(payload)))
    return
  end

  wezterm.log_info(payload)
end

return setmetatable(M, {
  __call = function(_, event)
    M.write(event)
  end,
})
