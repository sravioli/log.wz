local wezterm = require "wezterm"

---@class Log.Sinks
---@field wz     Log.Sink             WezTerm native logging sink.
---@field memory Log.Sinks.MemorySink In-memory log storage sink.
---@field json   Log.Sinks.Json       JSON encode/decode helpers and callable JSON sink.
---@field file   Log.Sinks.FileSink   File sink constructor for JSON or plain-text output.
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

local fallback_file = {
  new = function(_, _)
    return {
      sink = function()
        return no_op_sink()
      end,
      write = function(_)
        return nil
      end,
    }
  end,
}

local fallback_memory = {
  new = function()
    return {
      sink = function()
        return no_op_sink()
      end,
      write = function(_)
        return nil
      end,
      clear = function()
        return nil
      end,
      get_entries = function()
        return {}
      end,
      count = function()
        return 0
      end,
      to_string = function()
        return ""
      end,
    }
  end,
}

setmetatable(M, {
  __index = function(t, k)
    local modname = "log.sinks." .. k
    local ok, mod = pcall(require, modname)
    if not ok then
      wezterm.log_error(
        ("[Log.Sinks] Unable to load module %s: %s"):format(modname, tostring(mod))
      )

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
