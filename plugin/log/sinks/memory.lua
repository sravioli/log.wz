---@module "log.sinks.memory"

local DEFAULT_MAX_ENTRIES = 10000

---@class Log.Sinks.MemorySinkOptions
---@field max_entries? integer Maximum stored entries. Oldest entries are discarded when the limit is reached. 0 = unlimited. Defaults to 10 000.

---@class Log.Sinks.MemorySink
---@field max_entries integer Maximum stored entries (0 = unlimited).
local M = {}
M.__index = M

---Create new memory sink instance.
---
---@param opts? Log.Sinks.MemorySinkOptions
---@return Log.Sinks.MemorySink
function M.new(opts)
  opts = opts or {}
  return setmetatable({
    entries = {},
    max_entries = opts.max_entries or DEFAULT_MAX_ENTRIES,
  }, M)
end

---Store event in memory.
---
---When `max_entries` is reached the oldest entry is discarded.
---
---@param event Log.Event Log event to store.
function M:write(event)
  table.insert(self.entries, event)
  if self.max_entries > 0 and #self.entries > self.max_entries then
    table.remove(self.entries, 1)
  end
end

---Remove all stored log entries.
function M:clear()
  self.entries = {}
end

---Return shallow copy of stored entries.
---
---@return Log.Event[] entries Copy of stored log events.
function M:get_entries()
  local copy = {}
  for i = 1, #self.entries do
    copy[i] = self.entries[i]
  end
  return copy
end

---Get number of entries in memory.
---
---@return integer count Number of stored entries.
function M:count()
  return #self.entries
end

---Stringify all entries into human-readable lines.
---
---Formats entries as `[LEVEL] Message`, separated by newlines.
---
---@return string formatted_log Concatenated string of all log entries.
function M:to_string()
  local out = {}
  for i = 1, #self.entries do
    local e = self.entries[i]
    table.insert(out, ("[%s] %s"):format(e.level_name, e.message))
  end
  return table.concat(out, "\n")
end

---Return actual sink function expected by Log.
---
---Creates a closure wrapping the `write` method.
---
---@return fun(entry: Log.Event) sink_fn Sink function compatible with Log.
function M:sink()
  return function(event)
    self:write(event)
  end
end

return M
