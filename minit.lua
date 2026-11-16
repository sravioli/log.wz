---Minimal config for bug reports. Run it in isolation from your own config:
---
---    wezterm --config-file minit.lua
---
---Put your reproduction below the marker. Keep it as small as possible and
---paste the edited file into the bug report.
local wezterm = require "wezterm"
local log = wezterm.plugin.require "https://github.com/sravioli/log.wz"
local config = wezterm.config_builder()

-- Edit below this line --------------------------------------------------------

local logger = log.new "config"
logger:warn "Configuration loaded"

return config
