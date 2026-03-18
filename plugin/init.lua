---@class Wezterm
local wezterm = require "wezterm" --[[@as Wezterm]]

---Locate this plugin_dir and add it to package.path
---@return nil
local function bootstrap()
  -- selene: allow(incorrect_standard_library_use)
  local sep = package.config:sub(1, 1)

  for _, p in ipairs(wezterm.plugin.list()) do
    if p.url:find("log.wz", 1, true) then
      local base = p.plugin_dir .. sep .. "plugin" .. sep
      local path_entry = base .. "?.lua"
      local init_entry = base .. "?" .. sep .. "init.lua"
      if not package.path:find(path_entry, 1, true) then
        package.path = package.path .. ";" .. path_entry .. ";" .. init_entry
      end
      return p
    end
  end
end

bootstrap()

return require "log.api"
