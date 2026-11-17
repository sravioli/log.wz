---@module "log.deps"
---@author sravioli
---@license GNU-GPLv2

---Dependency loader. Prefers modules already on `package.path` (local dev
---checkouts, specs) and falls back to `wezterm.plugin.require`.

local wezterm = require "wezterm"

local M = {}

local warp

---Loaded on first use: only the file sink needs warp.
---@return Warp.Api
function M.warp()
  if not warp then
    local ok, mod = pcall(require, "warp.api")
    warp = ok and mod or wezterm.plugin.require "https://github.com/sravioli/warp.wz"
  end
  return warp
end

return M
