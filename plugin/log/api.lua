---@module "log.api"

---log.wz now lives in warp.wz as `warp.log`. This keeps the old URL working,
---and returns the same instance, so `log.setup` still reaches every plugin.

local wezterm = require "wezterm"

local ok, warp = pcall(require, "warp.api")
if not ok then
  warp = wezterm.plugin.require "https://github.com/sravioli/warp.wz"
end

---Same table as `warp.log`; see the warp.wz API reference.
---@class LogWz
local M = warp.log

return M
