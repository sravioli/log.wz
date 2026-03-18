---@module "log.levels"

---@class Log.Levels
local M = {}

---@enum Log.Levels.Level
M.levels = { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 }

---@type table<integer, string>
M.names = { [0] = "DEBUG", [1] = "INFO", [2] = "WARN", [3] = "ERROR" }

---Normalize log level from string or integer.
---
---If a string is provided (e.g., "info"), it is uppercased and mapped to its integer value.
---Returns `nil` for unrecognised level strings.
---
---@param level Log.Levels.Level|string|integer Level representation to normalize.
---@return integer? level Normalized numeric level, or nil if unrecognised.
function M.normalize(level)
  if type(level) == "string" then
    return M.levels[level:upper()]
  end
  if type(level) == "number" then
    return level
  end
  return nil
end

return M
