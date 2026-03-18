---@meta Log.Sinks
error "cannot require a meta file!"

---Lazy-loading registry for logger output sinks.
---
---Sub-modules are loaded on first access via `__index`.
---
---@class Log.Sinks
---@field public wz     Log.Sink             WezTerm native logging sink.
---@field public memory Log.Sinks.MemorySink In-memory log storage sink.
