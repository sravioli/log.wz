---@module "log.sinks.memory"

local DEFAULT_MAX_ENTRIES = 10000

---@class Log.Sinks.MemoryOpts
---@field max_entries? integer Maximum stored entries. Oldest are evicted when full. 0 = unlimited. Defaults to 10 000.

---@class Log.Sinks.MemorySink
---@field entries     Log.Event[] Stored log events.
---@field max_entries integer     Maximum stored entries (0 = unlimited).
local MemorySink = {}
MemorySink.__index = MemorySink

---Dispatch to write when used as a sink function.
---@param event Log.Event
function MemorySink:__call(event)
  self:write(event)
end

---Store event in memory.
---
---When `max_entries` is reached the oldest entry is discarded.
---
---@param event Log.Event Log event to store.
function MemorySink:write(event)
  table.insert(self.entries, event)
  if self.max_entries > 0 and #self.entries > self.max_entries then
    table.remove(self.entries, 1)
  end
end

---Remove all stored log entries.
function MemorySink:clear()
  self.entries = {}
end

---Return shallow copy of stored entries.
---
---@return Log.Event[] entries Copy of stored log events.
function MemorySink:get_entries()
  local copy = {}
  for i = 1, #self.entries do
    copy[i] = self.entries[i]
  end
  return copy
end

---Get number of entries in memory.
---
---@return integer count Number of stored entries.
function MemorySink:count()
  return #self.entries
end

---Stringify all entries into human-readable lines.
---
---Formats entries as `[LEVEL] Message`, separated by newlines.
---
---@return string formatted_log Concatenated string of all log entries.
function MemorySink:to_string()
  local out = {}
  for i = 1, #self.entries do
    local e = self.entries[i]
    table.insert(out, ("[%s] %s"):format(e.level_name, e.message))
  end
  return table.concat(out, "\n")
end

---Create a new memory sink.
---
---The returned instance is callable and can be passed directly to `Log:new`'s
---sinks array.
---
---@param opts? Log.Sinks.MemoryOpts
---@return Log.Sinks.MemorySink
return setmetatable({}, {
  __call = function(_, opts)
    opts = opts or {}
    return setmetatable({
      entries = {},
      max_entries = opts.max_entries or DEFAULT_MAX_ENTRIES,
    }, MemorySink)
  end,
})
