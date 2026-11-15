# log.wz

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/tests.yaml?style=flat-square&label=tests)](https://github.com/sravioli/log.wz/actions/workflows/tests.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/lint.yaml?style=flat-square&label=lint)](https://github.com/sravioli/log.wz/actions/workflows/lint.yaml)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/log.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/log.wz)
[![Code license](https://img.shields.io/badge/code-GPL--2.0-blue?style=flat-square)](../LICENSE)
[![Docs license](https://img.shields.io/badge/docs-CC_BY--NC_4.0-blue?style=flat-square)](../LICENSE-DOCS)

Tagged logging with configurable output sinks for [WezTerm](https://wezterm.org/).

Give each plugin or config module its own logger, filter messages by severity,
and send the same event to the debug overlay, a file, or an in-memory buffer.
One failing sink does not stop the others.

[Quick start](#quick-start) · [Usage](#usage) · [Configuration](#configuration) · [API reference](#api-reference) · [Troubleshooting](#troubleshooting) · [Development](#development) · [License](#license)

## Quick start

### Requirements

Requires **WezTerm [`20230320-124340-559cb7b0`](https://wezterm.org/config/lua/wezterm.plugin/require.html)
or newer** and Git. JSON sinks, including the default file format, also need
a **[nightly with serde support (2024-02-08) or newer](https://github.com/wezterm/wezterm/commit/8596422abf6257ecfb57b32396c56318c8231886)**.
Use `format = "text"` for files on stable builds.
No other plugins or special fonts are required.

### Install and run

Put this in `wezterm.lua`:

```lua
local wezterm = require "wezterm"
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"
local config = wezterm.config_builder()

local logger = log.new "config"
logger:warn "Configuration loaded"

return config
```

Reload your config and open WezTerm's debug overlay with **Ctrl+Shift+L**.
It shows `[config] Configuration loaded`. If you already have a config, keep
its builder and final `return`. Add the import and logger before that return.

## Usage

### Write to a file and the debug overlay

After the imports, configure logging before creating loggers:

```lua
log.setup { threshold = "INFO" }
local logger = log.new("config", true, {
  log.sinks.file { format = "text" },
})
logger:info("Window opacity = %s", 0.95)
```

The native sink remains enabled. Set `sinks.default_enabled = false` before
constructing the logger to write only to your supplied sinks.

The file sink chooses a data directory outside the config directory and creates
it if needed. For an explicit path, you must create the parent directories.
If it detects a path inside `wezterm.config_dir`, it moves the destination
outside and logs a warning to avoid config-reload loops.

### Capture messages for inspection

```lua
log.setup { threshold = "DEBUG" }
local memory = log.sinks.memory { max_entries = 100 }
local logger = log.new("picker", true, { memory })
logger:debug("Selected %s", "wave")
wezterm.log_info(memory:to_string())
```

You can also supply a sink function that receives one
[`Log.Event`](../plugin/log/api.lua). Events contain `timestamp` (epoch
seconds), `datetime` (local time), numeric `level`, `level_name`, `tag`,
formatted `message`, and the original format string as `raw_message`.
Keep sink callbacks short: logging calls them synchronously.

## Configuration

### Example

`log.setup` is optional. Call it after importing the plugin, before creating
loggers. This example changes the threshold and default sink:

```lua
log.setup {
  threshold = "ERROR",
  sinks = { default_enabled = false },
}
```

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `boolean` | `true` | Global switch, checked on every message. |
| `threshold` | `string\|integer` | `"WARN"` | Case-insensitive `DEBUG`, `INFO`, `WARN`, `ERROR`, or a numeric threshold. An unrecognized value falls back to `WARN` for new loggers. |
| `sinks.default_enabled` | `boolean` | `true` | Prepend the native WezTerm sink when constructing a logger. |

#### File sink options

Pass these to `log.sinks.file(opts)`, not `log.setup`.

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `string?` | `nil` | Computed destination: `log.wz.log` in the platform data directory when omitted. |
| `format` | `"json"\|"text"` | `"json"` | One JSON object or one formatted text line per event. Other values use the JSON branch. |
| `formatter` | `fun(event: Log.Event): string` | `nil` | Custom serializer; takes precedence over `format`. |

On Windows the directory is `%LOCALAPPDATA%\wezterm`, falling back to
`%APPDATA%\wezterm`. On other platforms it is `$XDG_DATA_HOME/wezterm`,
falling back to `$HOME/.local/share/wezterm`. If those environment variables
are unavailable, the file sink uses the current directory.
Check the returned sink's `path` to see where it will write.

#### Memory sink options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `max_entries` | `integer` | `10000` | Retained events; oldest entries are removed at capacity. `0` disables the limit. |

### Behavior and precedence

`log.setup(opts)` and `log:setup(opts)` both work; `log.config.setup(opts)`
uses the same configuration. Only known settings are accepted. Updates merge
the `sinks` map one level deep, retain omitted values, and ignore unknown keys
without a diagnostic. There is no general option-type validation.

Existing loggers retain their threshold and sink list. The global `enabled`
flag takes effect immediately. Each logger also exposes writable `enabled`,
`threshold`, `tag`, and `sinks` fields. A logger shallow-copies the supplied
sink list, but the sink instances remain shared.

Configuration, loggers, and memory buffers live only in Lua state. Reapply
setup after a config reload; files you wrote remain on disk.

## API reference

`?` marks an optional argument or nullable return. `nil` means no returned
value where a function is used only for its side effect.

### Loggers and configuration

| Signature → Return type | Description |
| --- | --- |
| `log.setup(options?) → nil` | Merge global settings; also callable as `log:setup(options)`. |
| `log.config.setup(options?) → nil` | Configure the same global settings. |
| `log.config.get() → Log.Config` | Return the live configuration table, not a defensive copy. |
| `log.new(tag?, enabled?, sinks?) → Log` | Create a logger; tag defaults to `"Log"`, enabled to `true`, supplied sinks to `{}`. |
| `logger:log(level, message, ...) → nil` | Emit at a string or numeric level when it meets the threshold. Unknown levels are dropped. |
| `logger:debug(message, ...) → nil` | Emit at `DEBUG`, prefixing the format string with `"DEBUG: "`. |
| `logger:info(message, ...) → nil` | Emit at `INFO`. |
| `logger:warn(message, ...) → nil` | Emit at `WARN`. |
| `logger:error(message, ...) → nil` | Emit at `ERROR`. |
| `logger:add_sink(sink) → nil` | Append a function or callable sink instance. |
| `log.levels.normalize(level) → integer?` | Normalize known strings case-insensitively; numbers pass through unchanged. |

Messages use `string.format`. Arguments are stringified before formatting;
use `%s` for objects. If formatting fails, Log emits the original message
instead of raising. It reports sink exceptions through `wezterm.log_error`.
The timestamp includes milliseconds when WezTerm's clock supports them;
the `os.time` fallback has second precision.

| Constant | Value | Meaning |
| --- | --- | --- |
| `log.levels.levels.DEBUG` | `0` | Diagnostic messages. |
| `log.levels.levels.INFO` | `1` | Informational messages. |
| `log.levels.levels.WARN` | `2` | Warnings; default threshold. |
| `log.levels.levels.ERROR` | `3` | Errors. |
| `log.levels.names` | `{ [0] = "DEBUG", [1] = "INFO", [2] = "WARN", [3] = "ERROR" }` | Reverse lookup. |

### Sink factories and operations

| Signature → Return type | Description |
| --- | --- |
| `log.sinks.wz(event) → nil` | Native sink: debug/info to `log_info`, warn to `log_warn`, error to `log_error`. |
| `log.sinks.json(event) → nil` | Callable alias of `log.sinks.json.write`. |
| `log.sinks.json.write(event) → nil` | Encode and emit JSON through `wezterm.log_info`; encoding failures are logged. |
| `log.sinks.json.encode(value) → string` | JSON-encode a value; missing serde support or invalid input raises. |
| `log.sinks.json.decode(payload) → any` | JSON-decode text; missing serde support or invalid JSON raises. |
| `log.sinks.file(options?) → Log.Sinks.FileSink` | Construct a callable file sink; see [options](#file-sink-options). |
| `file(event) → nil` | Callable alias of `file:write(event)`. |
| `file:write(event) → nil` | Serialize and append one line; failures are logged. |
| `file:serialize(event) → boolean, string` | Return success and payload, or `false` and an error message; does not write. |
| `file:append(payload) → boolean, string?` | Append raw text plus a newline; return an error on open/write/close failure. |
| `log.sinks.memory(options?) → Log.Sinks.MemorySink` | Construct a callable memory buffer; see [options](#memory-sink-options). |
| `memory(event) → nil` | Callable alias of `memory:write(event)`. |
| `memory:write(event) → nil` | Store the same event reference; evict the oldest entry at capacity. |
| `memory:clear() → nil` | Remove stored events. |
| `memory:get_entries() → Log.Event[]` | Shallow-copy the list; event tables remain shared. |
| `memory:count() → integer` | Count retained events. |
| `memory:to_string() → string` | Join events as `[LEVEL] message` lines. |

Sink modules load on first access. If a module fails to load, Log reports the
error and caches a no-op fallback. Empty output does not confirm a successful
write. See the [annotated source](../plugin/log/api.lua) for full event and sink types.

## Troubleshooting

### A message is missing

The default threshold is `WARN`. Configure a lower threshold before creating
the logger, and check both global and instance `enabled` flags. After changing
the default sink setting, recreate the logger.

### File output does not appear

Inspect `file.path` and the debug overlay. For an explicit path, create its
parent directories first. Check the overlay for write and custom-formatter
errors. JSON output also needs WezTerm's serde API.

Update installed plugins with `wezterm.plugin.update_all()` from the debug
overlay, then reload the config. Report reproducible problems in
[issues](https://github.com/sravioli/log.wz/issues), including your WezTerm
version, plugin revision, sink options, and relevant logs.

## Development

### Local checkout

Clone this repository into `plugins/log.wz` beneath `wezterm.config_dir`.
Replace the remote import in your config with:

```lua
local wezterm = require "wezterm"
local log = wezterm.plugin.require(
  "file:///" .. wezterm.config_dir .. "/plugins/log.wz"
)
```

### Editor support

Follow the [wezterm-types setup](https://github.com/DrKJeff16/wezterm-types)
for LuaLS. Its [Log definitions](https://github.com/DrKJeff16/wezterm-types/blob/main/lua/wezterm/types/plugins/log.lua)
include the module and sink APIs:

```lua
---@type Log.API
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"
```

Use `Log.API` for the module; `Log` describes a logger instance.
The [source annotations](../plugin/log/api.lua) describe the API in this revision.

### Checks and contributions

From the repository root, with Lua 5.4 and the named tools installed:

```sh
busted --verbose
luacheck plugin spec
selene --display-style=quiet plugin
stylua --check plugin spec
```

Specs use a WezTerm mock; verify GUI logging and file output in WezTerm too.
See the [contribution guide](contributing.md). Keep source, tests, and
documentation changes focused, and use Conventional Commits.

## License

Code: [GNU GPL v2](../LICENSE). Documentation:
[CC BY-NC 4.0](../LICENSE-DOCS). Preserve the attribution in the source and
license files when redistributing.
