---@meta Log.Sinks.MemorySink
error "cannot require a meta file!"

-- luacheck: push ignore 631 (line is too long)

---In-memory log event storage.
---
---Collect log events in a list for later inspection, testing, or serialisation.
---
---### Example Usage
---~~~lua
---local MemorySink = require("log.sinks.memory")
---local mem = MemorySink.new()
---local log = require("log"):new("Test", true, { mem:sink() })
---log:info("hello %s", "world")
---print(mem:count())      -- 1
---print(mem:to_string())  -- [INFO] [Test] hello "world"
---~~~
---
---@class Log.Sinks.MemorySink
---@field public entries Log.Event[] List of stored log events.

-- luacheck: pop
