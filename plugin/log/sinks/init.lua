---@class Log.Sinks
---@field wz     Log.Sink                                               WezTerm native logging sink.
---@field json   Log.Sinks.Json                                         JSON encode/decode helpers and JSON sink.
---@field memory fun(opts?: Log.Sinks.MemoryOpts): Log.Sinks.MemorySink Memory sink constructor.
---@field file   fun(opts?: Log.Sinks.FileOpts): Log.Sinks.FileSink     File sink constructor.

---Sinks load on first use. They ship with this plugin, so a failed load is a
---broken install and raises; an unknown name such as a typo raises too.
return setmetatable({}, {
  __index = function(t, k)
    local mod = require("log.sinks." .. k)
    rawset(t, k, mod)
    return mod
  end,
})
