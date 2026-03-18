---@class Log.Sinks
local M = {}

setmetatable(M, {
  __index = function(t, k)
    local modname = "log.sinks." .. k
    local ok, mod = pcall(require, modname)
    if not ok then
      return require("log.api"):new("Log.Sinks"):error(
      "Unable to load module %s",
        modname
      )
    end

    rawset(t, k, mod)
    return mod
  end,
})

return M
