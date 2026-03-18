# log.wz

[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/log.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/log.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/log.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/log.wz)

Logging library for [WezTerm](https://wezfurlong.org/wezterm/) plugins and
configuration code.

- Tagged logger instances with per-instance enable/disable
- Global threshold filtering (`DEBUG`, `INFO`, `WARN`, `ERROR`)
- Pluggable sinks: WezTerm native, JSON, file, in-memory ring buffer
- File sink auto-resolves a safe log directory outside `config_dir`
- Sink errors isolated with `pcall`; format-string errors caught gracefully
- Lazy-loaded sink modules with no-op fallbacks

## Installation

```lua
local wezterm = require "wezterm"

-- from git
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"

-- from a local checkout
local log = wezterm.plugin.require("file:///" .. wezterm.config_dir .. "/plugins/log.wz")
```

## Usage

```lua
log:setup { threshold = "INFO" }

local logger = log.new "wezterm.lua"
logger:warn "Configuration loaded"
logger:info("Window opacity = %s", 0.95)
```

`message` uses `string.format` placeholders. Non-string arguments are
stringified automatically. Malformed format strings emit the raw message
instead of crashing.

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

Existing loggers keep their original threshold and sinks. The global
`enabled` flag takes effect immediately.

## Logger

```lua
local logger = log.new(tag?, enabled?, sinks?)
```

| Param     | Type        | Default | Notes                          |
| --------- | ----------- | ------- | ------------------------------ |
| `tag`     | string?     | `"Log"` | Prefix shown in output.        |
| `enabled` | boolean?    | `true`  | Per-instance toggle.           |
| `sinks`   | Log.Sink[]? | `{}`    | Shallow-copied, never mutated. |

When `sinks.default_enabled` is true the WezTerm sink is prepended
automatically.

### Methods

| Method                        | Description                          |
| ----------------------------- | ------------------------------------ |
| `logger:debug(message, ...)`  | DEBUG level. Prepends `"DEBUG: "`.   |
| `logger:info(message, ...)`   | INFO level.                          |
| `logger:warn(message, ...)`   | WARN level.                          |
| `logger:error(message, ...)`  | ERROR level.                         |
| `logger:log(level, msg, ...)` | Arbitrary level (string or integer). |
| `logger:add_sink(sink)`       | Append a sink after creation.        |

## Levels

| Name    | Value |
| ------- | ----- |
| `DEBUG` | 0     |
| `INFO`  | 1     |
| `WARN`  | 2     |
| `ERROR` | 3     |

Events are emitted when `event.level >= logger.threshold`. Unrecognised levels
are silently dropped.

## Event

Every sink receives a table with these fields:

| Field         | Type    | Description                    |
| ------------- | ------- | ------------------------------ |
| `timestamp`   | integer | Unix epoch seconds.            |
| `datetime`    | string  | `%Y-%m-%d %H:%M:%S%.3f` local. |
| `level`       | integer | Numeric severity.              |
| `level_name`  | string  | `"DEBUG"`, `"INFO"`, etc.      |
| `tag`         | string  | Logger tag.                    |
| `message`     | string  | Formatted message.             |
| `raw_message` | string  | Message before formatting.     |

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

Each sink runs inside `pcall`. A failing sink is logged to the WezTerm debug
overlay and does not affect other sinks.

If a sink module fails to load, a no-op fallback is used.

---

### `log.sinks.wz`

Default sink. Forwards to WezTerm's native logging.

| Level       | Calls               |
| ----------- | ------------------- |
| DEBUG, INFO | `wezterm.log_info`  |
| WARN        | `wezterm.log_warn`  |
| ERROR       | `wezterm.log_error` |

---

### `log.sinks.json`

Callable sink. Encodes events as JSON and emits them through
`wezterm.log_info`. Uses `wezterm.serde` internally.

```lua
local logger = log.new("app", true, { log.sinks.json })
```

Also exposes `encode(value)`, `decode(payload)`, and `write(event)` as static
functions.

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
| `formatter` | `fun(event): string` | —        | Custom formatter. Overrides `format`.     |

#### Path handling

| `path`                      | Behaviour                                                                                                      |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| nil / omitted               | Uses platform default directory, file `log.wz.log`.                                                            |
| Inside `wezterm.config_dir` | Relocated to the default directory with a warning. Writing inside `config_dir` causes an infinite reload loop. |
| Anything else               | Used as-is.                                                                                                    |

Default directory:

| OS            | Path                                                         |
| ------------- | ------------------------------------------------------------ |
| Windows       | `%LOCALAPPDATA%\wezterm` (fallback `%APPDATA%\wezterm`)      |
| Linux / macOS | `$XDG_DATA_HOME/wezterm` (fallback `~/.local/share/wezterm`) |

The directory is created if it doesn't exist.

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

## License

Code is licensed under the [GNU General Public License v2](../LICENSE). Documentation
is licensed under [Creative Commons Attribution-NonCommercial 4.0 International](../LICENSE-DOCS).
