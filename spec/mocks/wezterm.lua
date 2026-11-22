---Minimal wezterm mock: just enough to load warp from a sibling checkout.

if package.loaded["wezterm"] then
  return package.loaded["wezterm"]
end

package.path = "../warp.wz/plugin/?.lua;../warp.wz/plugin/?/init.lua;" .. package.path

-- selene: allow(incorrect_standard_library_use)
local sep = package.config:sub(1, 1)
local M = {
  target_triple = sep == "\\" and "x86_64-pc-windows-msvc" or "x86_64-unknown-linux-gnu",
  home_dir = os.getenv "HOME" or os.getenv "USERPROFILE",
  column_width = function(s)
    return utf8.len(s) or #s
  end,
  plugin = {
    require = function(url)
      error("unexpected plugin.require: " .. tostring(url))
    end,
  },
}

package.loaded["wezterm"] = M

return M
