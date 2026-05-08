# log.wz

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/log.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/log.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/log.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/log.wz)

Logging for [WezTerm](https://wezfurlong.org/wezterm/) plugins and configs.

- Tagged logger instances with per-instance enable/disable
- Global threshold filtering (`DEBUG`, `INFO`, `WARN`, `ERROR`)
- Pluggable sinks: WezTerm native, JSON, file, in-memory ring buffer
- File sink that chooses a safe log directory outside `config_dir`
- Sink errors are isolated with `pcall`; malformed format strings do not crash
  WezTerm
- Lazy-loaded sink modules with no-op fallbacks
- LuaLS annotations for editor completion and type checking

## Installation

```lua
local wezterm = require "wezterm"

-- from git
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"

-- from a local checkout
local log = wezterm.plugin.require("file:///" .. wezterm.config_dir .. "/plugins/log.wz")
```

### Type annotations

Log ships LuaCATS annotations. After installing
[wezterm-types](https://github.com/DrKJeff16/wezterm-types), annotate the import
to get completion and type checking:

```lua
---@type Log
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"
```

## Usage

```lua
log:setup { threshold = "INFO" }

local logger = log.new "wezterm.lua"
logger:warn "Configuration loaded"
logger:info("Window opacity = %s", 0.95)
```

`message` uses `string.format` placeholders. Non-string arguments are converted
automatically (`userdata` via `tostring`, everything else through
`wezterm.to_string` when available). If a format string is malformed, log.wz
emits the raw message instead of raising an error.

Output is prefixed as `[tag] message`.

## Configuration

Call `setup` before creating loggers. Both `log.setup(t)` and `log:setup(t)`
work.

```lua
log:setup {
  enabled = true,         -- global on/off
  threshold = "INFO",     -- DEBUG | INFO | WARN | ERROR (or 0..3)
  sinks = {
    default_enabled = true, -- prepend built-in WezTerm sink to every logger
  },
}
```

| Field                   | Type             | Default  | Description                                  |
| ----------------------- | ---------------- | -------- | -------------------------------------------- |
| `enabled`               | boolean          | `true`   | Global on/off.                               |
| `threshold`             | string \| number | `"WARN"` | Minimum level. Invalid values become `WARN`. |
| `sinks.default_enabled` | boolean          | `true`   | Auto-prepend the WezTerm sink.               |

Only keys present in the defaults are accepted. Unknown keys are ignored, and
the `sinks` table is merged one level deep.

Existing loggers keep the threshold and sinks they were created with. The global
`enabled` flag takes effect immediately.

The current configuration can be read with `log.config.get()`. It returns a
reference to the live config table.

## Logger

```lua
local logger = log.new(tag?, enabled?, sinks?)
```

| Param     | Type        | Default | Notes                          |
| --------- | ----------- | ------- | ------------------------------ |
| `tag`     | string?     | `"Log"` | Prefix shown in output.        |
| `enabled` | boolean?    | `true`  | Per-instance toggle.           |
| `sinks`   | Log.Sink[]? | `{}`    | Shallow-copied, never mutated. |

When `sinks.default_enabled` is true, log.wz prepends the WezTerm sink
automatically. The logger reads the global threshold when it is created.

### Methods

| Method                        | Description                          |
| ----------------------------- | ------------------------------------ |
| `logger:debug(message, ...)`  | DEBUG level. Prepends `"DEBUG: "`.   |
| `logger:info(message, ...)`   | INFO level.                          |
| `logger:warn(message, ...)`   | WARN level.                          |
| `logger:error(message, ...)`  | ERROR level.                         |
| `logger:log(level, msg, ...)` | Arbitrary level (string or integer). |
| `logger:add_sink(sink)`       | Append a sink after creation.        |

A message is emitted only when logging is enabled globally, the logger itself is
enabled, and the resolved level is at or above the logger's threshold.

## Levels

| Name    | Value |
| ------- | ----- |
| `DEBUG` | 0     |
| `INFO`  | 1     |
| `WARN`  | 2     |
| `ERROR` | 3     |

Access the enum via `log.levels.levels` and the reverse map via
`log.levels.names`. Use `log.levels.normalize(level)` to convert a string or
number into a numeric level. String matching is case-insensitive. Unknown
strings return `nil`; numeric values pass through unchanged.

Events are emitted when `event.level >= logger.threshold`. Unknown levels are
dropped.

## Event

Every sink receives a table with these fields:

| Field         | Type    | Description                    |
| ------------- | ------- | ------------------------------ |
| `timestamp`   | integer | Unix epoch seconds.            |
| `datetime`    | string  | `%Y-%m-%d %H:%M:%S%.3f` local. |
| `level`       | integer | Numeric severity.              |
| `level_name`  | string  | `"DEBUG"`, `"INFO"`, etc.      |
| `tag`         | string  | Logger tag.                    |
| `message`     | string  | Formatted message with tag.    |
| `raw_message` | string  | Message before formatting.     |

Timestamps use `wezterm.time.now()` when available and fall back to `os.time()`.

## Sinks

A sink is a function or callable table that receives a `Log.Event`.

| Kind      | What             | How to use                             |
| --------- | ---------------- | -------------------------------------- |
| Stateless | `wz`, `json`     | Pass directly: `{ log.sinks.json }`    |
| Stateful  | `memory`, `file` | Call to create: `{ log.sinks.file() }` |

Stateful modules return callable instances. Pass them straight into the sinks
array.

```lua
local logger = log.new("tag", true, {
  log.sinks.json,
  log.sinks.file { format = "text" },
})
```

Each sink runs inside `pcall`. If one sink fails, log.wz reports the error to
the WezTerm debug overlay and keeps writing to the other sinks.

Sink modules are loaded on first access. If a module cannot load, log.wz returns
a no-op fallback and reports the error through `wezterm.log_error`.

---

### `log.sinks.wz`

The default sink forwards events to WezTerm's native logging functions.

| Level       | Calls               |
| ----------- | ------------------- |
| DEBUG, INFO | `wezterm.log_info`  |
| WARN        | `wezterm.log_warn`  |
| ERROR       | `wezterm.log_error` |

Unknown levels are ignored.

---

### `log.sinks.json`

Callable sink. It encodes events as JSON and emits them through
`wezterm.log_info`. It uses `wezterm.serde` internally and raises an error if
`wezterm.serde` is unavailable.

```lua
local logger = log.new("app", true, { log.sinks.json })
```

Also exposes utility functions:

| Function                    | Description                                  |
| --------------------------- | -------------------------------------------- |
| `log.sinks.json.encode(v)`  | Encode a Lua value to a JSON string.         |
| `log.sinks.json.decode(s)`  | Decode a JSON string back to a Lua value.    |
| `log.sinks.json.write(evt)` | Encode event as JSON and log via `log_info`. |

---

### `log.sinks.memory`

In-memory ring buffer. Call the module to create an instance.

```lua
local mem = log.sinks.memory()                      -- default: 10 000 entries
local mem = log.sinks.memory { max_entries = 500 }   -- custom cap
local mem = log.sinks.memory { max_entries = 0 }     -- unlimited

local logger = log.new("test", true, { mem })
logger:info("hello %s", "world")

mem:count()        -- 1
mem:get_entries()  -- shallow copy of stored events
mem:to_string()    -- "[INFO] [test] hello world"
mem:clear()
```

| Method          | Returns       | Description                             |
| --------------- | ------------- | --------------------------------------- |
| `write(event)`  | nil           | Store event. Evicts oldest when full.   |
| `clear()`       | nil           | Remove all stored entries.              |
| `get_entries()` | `Log.Event[]` | Shallow copy of stored events.          |
| `count()`       | integer       | Number of stored entries.               |
| `to_string()`   | string        | Entries formatted as `[LEVEL] message`. |

---

### `log.sinks.file`

Appends one line per event to a file. Call the module to create an instance.

```lua
local f = log.sinks.file()                                  -- default path, JSON
local f = log.sinks.file { format = "text" }                -- default path, plain text
local f = log.sinks.file { path = "/tmp/wz.log" }          -- explicit path
local f = log.sinks.file {                                  -- custom formatter
  formatter = function(e)
    return ("%s | %s | %s"):format(e.datetime, e.level_name, e.message)
  end,
}

local logger = log.new("app", true, { f })
```

#### Options

| Field       | Type                 | Default  | Description                               |
| ----------- | -------------------- | -------- | ----------------------------------------- |
| `path`      | string?              | auto     | File path. Resolved automatically if nil. |
| `format`    | `"json"` \| `"text"` | `"json"` | Line format.                              |
| `formatter` | `fun(event): string` | `nil`    | Custom formatter. Overrides `format`.     |

#### Path handling

| `path`                      | Behaviour                                                                                                      |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| nil / omitted               | Uses platform default directory, file `log.wz.log`.                                                            |
| Inside `wezterm.config_dir` | Relocated to the default directory with a warning. Writing inside `config_dir` causes an infinite reload loop. |
| Anything else               | Used as-is. Parent directories are **not** auto-created for explicit paths.                                    |

Default directory:

| OS            | Path                                                         |
| ------------- | ------------------------------------------------------------ |
| Windows       | `%LOCALAPPDATA%\wezterm` (fallback `%APPDATA%\wezterm`)      |
| Linux / macOS | `$XDG_DATA_HOME/wezterm` (fallback `~/.local/share/wezterm`) |

The default directory is created automatically if it doesn't exist.

#### Output formats

**JSON** (default):

```json
{
  "timestamp": 1234567890,
  "datetime": "2025-01-01 00:00:00.000",
  "level": 2,
  "level_name": "WARN",
  "tag": "MyTag",
  "message": "[MyTag] Hello",
  "raw_message": "Hello"
}
```

**Text**:

```
2025-01-01 00:00:00.000 [WARN] [MyTag] Hello
```

| Method             | Returns            | Description                         |
| ------------------ | ------------------ | ----------------------------------- |
| `write(event)`     | nil                | Serialize and append event to file. |
| `serialize(event)` | `boolean, string`  | Serialize event without writing.    |
| `append(payload)`  | `boolean, string?` | Append raw text to the file.        |

## Examples

Log to both WezTerm and a file (default sink enabled):

```lua
local logger = log.new("wezterm.lua", true, { log.sinks.file() })
logger:warn "starting up"
```

Log only to a file:

```lua
log:setup { sinks = { default_enabled = false } }
local logger = log.new("wezterm.lua", true, { log.sinks.file { format = "text" } })
```

Capture in memory:

```lua
log:setup { threshold = "DEBUG" }
local mem = log.sinks.memory { max_entries = 100 }
local logger = log.new("test", true, { mem })
logger:debug "step 1"
assert(mem:count() == 1)
```

Multiple sinks at once:

```lua
local mem = log.sinks.memory()
local logger = log.new("app", true, {
  log.sinks.json,
  log.sinks.file { format = "text" },
  mem,
})
logger:info("started with %s sinks", #logger.sinks)
```

## License

Code is licensed under the [GNU General Public License v2](../LICENSE).
Documentation is licensed under
[Creative Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS).
