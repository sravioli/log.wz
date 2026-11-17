---@module "log.sinks.memory"

local DEFAULT_MAX_ENTRIES = 10000

---@class Log.Sinks.MemoryOpts
---@field max_entries? integer Maximum stored entries. Oldest are evicted when full. 0 = unlimited. Defaults to 10 000.

---Events live in a ring buffer, so a full sink evicts in O(1) instead of
---shifting every entry. `entries` is read as a fresh oldest-first list.
---@class Log.Sinks.MemorySink
---@field entries     Log.Event[] Stored log events, oldest first (a copy).
---@field max_entries integer     Maximum stored entries (0 = unlimited).
local MemorySink = {}
MemorySink.__index = function(self, key)
  if key == "entries" then
    return self:get_entries()
  end
  return MemorySink[key]
end

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
  local max = self.max_entries
  if max > 0 and self._count == max then
    -- Overwrite the oldest slot and move the start past it.
    self._buf[self._first] = event
    self._first = self._first % max + 1
    return
  end
  self._count = self._count + 1
  local slot = self._count
  if max > 0 then
    slot = (self._first + self._count - 2) % max + 1
  end
  self._buf[slot] = event
end

---Remove all stored log entries.
function MemorySink:clear()
  self._buf, self._first, self._count = {}, 1, 0
end

---Return shallow copy of stored entries, oldest first.
---
---@return Log.Event[] entries Copy of stored log events.
function MemorySink:get_entries()
  local copy, max = {}, self.max_entries
  for i = 1, self._count do
    local slot = max > 0 and (self._first + i - 2) % max + 1 or i
    copy[i] = self._buf[slot]
  end
  return copy
end

---Get number of entries in memory.
---
---@return integer count Number of stored entries.
function MemorySink:count()
  return self._count
end

---Stringify all entries into human-readable lines.
---
---Formats entries as `[LEVEL] Message`, separated by newlines.
---
---@return string formatted_log Concatenated string of all log entries.
function MemorySink:to_string()
  local out = {}
  for i, e in ipairs(self:get_entries()) do
    out[i] = ("[%s] %s"):format(e.level_name, e.message)
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
    local sink = setmetatable({
      max_entries = opts.max_entries or DEFAULT_MAX_ENTRIES,
    }, MemorySink)
    sink:clear()
    return sink
  end,
})
