# log.wz [![Release](https://img.shields.io/github/v/release/sravioli/log.wz?style=flat&label=Release&logo=github)](https://github.com/sravioli/log.wz/releases/latest)

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/tests.yaml?style=flat&label=Tests&logo=githubactions)](https://github.com/sravioli/log.wz/actions/workflows/tests.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/log.wz/lint.yaml?style=flat&label=Lint&logo=githubactions)](https://github.com/sravioli/log.wz/actions/workflows/lint.yaml)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/log.wz?style=flat&label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/log.wz)
[![Code license](https://img.shields.io/badge/Code-GPL--2.0-blue?style=flat&logo=gnu)](../LICENSE)
[![Docs license](https://img.shields.io/badge/Docs-CC_BY--NC_4.0-blue?style=flat&logo=creativecommons)](../LICENSE-DOCS)

Tagged logging with configurable output sinks for [WezTerm](https://wezterm.org/).

Give each plugin or config module its own logger, and filter messages by
severity. Send the same event to the debug overlay, a file, or a buffer in
memory.
One failing sink does not stop the others.

[Quick start](#quick-start) · [Usage](#usage) · [Configuration](#configuration) · [API reference](#api-reference) · [Troubleshooting](#troubleshooting) · [Development](#development) · [License](#license)

## Quick start

### Requirements

Requires **WezTerm [`20230320-124340-559cb7b0`](https://wezterm.org/config/lua/wezterm.plugin/require.html)
or newer** and Git. JSON sinks, including the default file format, also need
a **[nightly with serde support (2024-02-08) or newer](https://github.com/wezterm/wezterm/commit/8596422abf6257ecfb57b32396c56318c8231886)**.
Use `format = "text"` for files on stable builds.
The file sink loads [warp.wz](https://github.com/sravioli/warp.wz) the first
time you create one; `wezterm.plugin.require` fetches it for you. No other
plugins or special fonts are required.

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

| Option                  | Type              | Default  | Description                                                                                                                            |
| ----------------------- | ----------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `enabled`               | `boolean`         | `true`   | Global switch, checked on every message.                                                                                               |
| `threshold`             | `string\|integer` | `"WARN"` | Case-insensitive `DEBUG`, `INFO`, `WARN`, `ERROR`, or a numeric threshold. An unrecognized value falls back to `WARN` for new loggers. |
| `sinks.default_enabled` | `boolean`         | `true`   | Prepend the native WezTerm sink when constructing a logger.                                                                            |

#### File sink options

Pass these to `log.sinks.file(opts)`, not `log.setup`.

| Option      | Type                            | Default  | Description                                                                             |
| ----------- | ------------------------------- | -------- | --------------------------------------------------------------------------------------- |
| `path`      | `string?`                       | `nil`    | Computed destination: `log.wz.log` in the platform data directory when omitted.         |
| `format`    | `"json"\|"text"`                | `"json"` | One JSON object or one formatted text line per event. Other values use the JSON branch. |
| `formatter` | `fun(event: Log.Event): string` | `nil`    | Custom serializer. Takes precedence over `format`.                                      |

On Windows the directory is `%LOCALAPPDATA%\wezterm`, falling back to
`%APPDATA%\wezterm`. On other platforms it is `$XDG_DATA_HOME/wezterm`,
falling back to `$HOME/.local/share/wezterm`. If those environment variables
are unavailable, the file sink uses the current directory.
Check the returned sink's `path` to see where it will write.

#### Memory sink options

| Option        | Type      | Default | Description                                                                      |
| ------------- | --------- | ------- | -------------------------------------------------------------------------------- |
| `max_entries` | `integer` | `10000` | Retained events. Oldest entries are removed at capacity. `0` disables the limit. |

### Behavior and precedence

`log.setup(opts)` and `log:setup(opts)` both work. `log.config.setup(opts)`
uses the same configuration. Only known settings are accepted. Updates merge
the `sinks` map one level deep, retain omitted values, and ignore unknown keys
without a diagnostic. There is no general option-type validation.

Existing loggers retain their threshold and sink list. The global `enabled`
flag takes effect immediately. Each logger also exposes writable `enabled`,
`threshold`, `tag`, and `sinks` fields. A logger shallow-copies the supplied
sink list, but the sink instances remain shared.

Configuration, loggers, and memory buffers live only in Lua state. Reapply
setup after a config reload. Files you wrote remain on disk.

## API reference

The [API reference](../docs/api.md) lists every function, method, and value
with its parameters and return values. It is generated from the LuaLS
annotations in `plugin/`, so it matches the code. It has these sections:

- [log](../docs/api.md#log)
- [log.sinks](../docs/api.md#logsinks)
- [log.levels](../docs/api.md#loglevels)
- [log.config](../docs/api.md#logconfig)
- [Log](../docs/api.md#log)
- [Log.Sinks.FileSink](../docs/api.md#logsinksfilesink)
- [Log.Sinks.Json](../docs/api.md#logsinksjson)
- [Log.Sinks.MemorySink](../docs/api.md#logsinksmemorysink)
- [Types](../docs/api.md#types)

`?` marks an optional argument or nullable return. `nil` means no returned
value where a function is used only for its side effect.

### Loggers and configuration

Messages use `string.format`. Arguments are stringified before formatting.
Use `%s` for objects. If formatting fails, Log emits the original message
instead of raising. It reports sink exceptions through `wezterm.log_error`.
The timestamp includes milliseconds when WezTerm's clock supports them.
The `os.time` fallback has second precision.

| Constant                  | Value                                                          | Meaning                      |
| ------------------------- | -------------------------------------------------------------- | ---------------------------- |
| `log.levels.levels.DEBUG` | `0`                                                            | Diagnostic messages.         |
| `log.levels.levels.INFO`  | `1`                                                            | Informational messages.      |
| `log.levels.levels.WARN`  | `2`                                                            | Warnings. Default threshold. |
| `log.levels.levels.ERROR` | `3`                                                            | Errors.                      |
| `log.levels.names`        | `{ [0] = "DEBUG", [1] = "INFO", [2] = "WARN", [3] = "ERROR" }` | Reverse lookup.              |

### Sink factories and operations

Sink modules load on first access. A sink that fails to load, or an unknown
sink name, raises an error. The memory sink keeps its events in a ring buffer,
so a full sink drops the oldest event in constant time. See the [annotated source](../plugin/log/api.lua) for full event and sink types.

## Troubleshooting

### A message is missing

The default threshold is `WARN`. Lower it with `log:setup { threshold = "DEBUG" }`;
loggers follow it unless you set `logger.threshold` yourself. Check both the
global and the instance `enabled` flags. After changing the default sink
setting, recreate the logger.

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

Load the working tree directly, so edits take effect on the next config
reload without a commit or a plugin update. Adjust the path to your clone:

```lua
local wezterm = require "wezterm"
local root = wezterm.home_dir .. "/path/to/log.wz/plugin/"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path
local log = require "log.api"
```

### Editor support

Follow the [wezterm-types setup](https://github.com/DrKJeff16/wezterm-types)
for LuaLS. Its [Log definitions](https://github.com/DrKJeff16/wezterm-types/blob/main/lua/wezterm/types/plugins/log.lua)
include the module and sink APIs:

```lua
---@type Log.API
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"
```

Use `Log.API` for the module. `Log` describes a logger instance.
The [source annotations](../plugin/log/api.lua) describe the API in this revision.

### Checks and contributions

From the repository root, with Lua 5.4 and the named tools installed:

```sh
busted --verbose
luacheck plugin spec
selene --display-style=quiet plugin
stylua --check plugin spec
```

Specs use a WezTerm mock. Check GUI logging and file output in WezTerm too.
See the [contribution guide](contributing.md). Keep source, tests, and
documentation changes focused, and use Conventional Commits.

## License

Code: [GNU GPL v2](../LICENSE). Documentation:
[CC BY-NC 4.0](../LICENSE-DOCS). Preserve existing attribution.
