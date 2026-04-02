local wezterm = require "wezterm"

---@class Log.Sinks
---@field wz     Log.Sink                                               WezTerm native logging sink.
---@field json   Log.Sinks.Json                                         JSON encode/decode helpers and JSON sink.
---@field memory fun(opts?: Log.Sinks.MemoryOpts): Log.Sinks.MemorySink Memory sink constructor.
---@field file   fun(opts?: Log.Sinks.FileOpts): Log.Sinks.FileSink     File sink constructor.
local M = {}

local function no_op_sink()
  return function(_) end
end

local fallback_json = setmetatable({
  encode = function(_)
    return "{}"
  end,
  decode = function(_)
    return {}
  end,
  write = function(_)
    return nil
  end,
}, {
  __call = function(_, _)
    return nil
  end,
})

local fallback_file = setmetatable({}, {
  __call = function(_, _)
    return setmetatable({
      path = ".",
      format = "json",
      write = function(_, _) end,
    }, { __call = function(_, _) end })
  end,
})

local fallback_memory = setmetatable({}, {
  __call = function(_, _)
    return setmetatable({
      entries = {},
      max_entries = 0,
      write = function(_, _) end,
      clear = function(_) end,
      get_entries = function(_)
        return {}
      end,
      count = function(_)
        return 0
      end,
      to_string = function(_)
        return ""
      end,
    }, { __call = function(_, _) end })
  end,
})

setmetatable(M, {
  __index = function(t, k)
    local modname = "log.sinks." .. k
    local ok, mod = pcall(require, modname)
    if not ok then
      wezterm.log_error(("[Log.Sinks] Unable to load module %s: %s"):format(modname, tostring(mod)))

      if k == "file" then
        rawset(t, k, fallback_file)
        return fallback_file
      end
      if k == "json" then
        rawset(t, k, fallback_json)
        return fallback_json
      end
      if k == "memory" then
        rawset(t, k, fallback_memory)
        return fallback_memory
      end

      rawset(t, k, no_op_sink())
      return t[k]
    end

    rawset(t, k, mod)
    return mod
  end,
})

return M
