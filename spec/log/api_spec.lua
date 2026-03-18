local api = require "log.api"
local config = require "log.config"
local levels = require "log.levels"
local wezterm_mock = require "wezterm"

describe("log.api", function()
  local captured

  -- lightweight spy sink: stores events it receives
  local function spy_sink()
    captured = {}
    return function(event)
      captured[#captured + 1] = event
    end
  end

  before_each(function()
    wezterm_mock._reset()
    -- Reset config to known state; disable default sink so tests only see spy
    config.setup {
      enabled = true,
      threshold = "DEBUG",
      sinks = { default_enabled = false },
    }
    captured = {}
  end)

  -- ──────────────────────────────
  -- Constructor
  -- ──────────────────────────────
  describe("Log.new()", function()
    it("returns a logger with default tag", function()
      local log = api.new()
      assert.are.equal("Log", log.tag)
    end)

    it("accepts a custom tag", function()
      local log = api.new "MyTag"
      assert.are.equal("MyTag", log.tag)
    end)

    it("defaults enabled to true", function()
      local log = api.new()
      assert.is_true(log.enabled)
    end)

    it("respects explicit enabled=false", function()
      local log = api.new("T", false)
      assert.is_false(log.enabled)
    end)

    it("copies user sinks without mutation", function()
      local s = spy_sink()
      local original = { s }
      local log = api.new("T", true, original)
      -- adding a sink on the logger shouldn't touch the original table
      log:add_sink(function() end)
      assert.are.equal(1, #original)
    end)

    it("prepends default sink when default_enabled is true", function()
      config.setup { sinks = { default_enabled = true } }
      local s = spy_sink()
      local log = api.new("T", true, { s })
      -- first sink is the wz default, second is our spy
      assert.are.equal(2, #log.sinks)
    end)

    it("does not prepend default sink when default_enabled is false", function()
      config.setup { sinks = { default_enabled = false } }
      local s = spy_sink()
      local log = api.new("T", true, { s })
      assert.are.equal(1, #log.sinks)
    end)

    it("uses config threshold", function()
      config.setup { threshold = "ERROR" }
      local log = api.new()
      assert.are.equal(levels.levels.ERROR, log.threshold)
    end)

    it("falls back to WARN when threshold is unrecognised", function()
      config.setup { threshold = "UNKNOWN" }
      local log = api.new()
      assert.are.equal(levels.levels.WARN, log.threshold)
    end)
  end)

  -- ──────────────────────────────
  -- add_sink
  -- ──────────────────────────────
  describe("Log:add_sink()", function()
    it("appends a sink", function()
      local log = api.new("T", true, {})
      local s = spy_sink()
      log:add_sink(s)
      assert.are.equal(1, #log.sinks)
    end)
  end)

  -- ──────────────────────────────
  -- log()
  -- ──────────────────────────────
  describe("Log:log()", function()
    it("emits event at matching level", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("DEBUG", "hello")
      assert.are.equal(1, #captured)
      assert.are.equal(levels.levels.DEBUG, captured[1].level)
      assert.are.equal("DEBUG", captured[1].level_name)
      assert.are.equal("T", captured[1].tag)
      assert.truthy(captured[1].message:find "hello")
      assert.are.equal("hello", captured[1].raw_message)
    end)

    it("formats message with string.format args", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("WARN", "count=%d", 42)
      assert.truthy(captured[1].message:find "count=42")
    end)

    it("does not emit below threshold", function()
      config.setup { threshold = "ERROR" }
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("WARN", "nope")
      assert.are.equal(0, #captured)
    end)

    it("does not emit when logger is disabled", function()
      local s = spy_sink()
      local log = api.new("T", false, { s })
      log:log("ERROR", "nope")
      assert.are.equal(0, #captured)
    end)

    it("does not emit when global config is disabled", function()
      config.setup { enabled = false }
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "nope")
      assert.are.equal(0, #captured)
    end)

    it("returns nil for invalid level", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log(true, "bad level")
      assert.are.equal(0, #captured)
    end)

    it("falls back to raw message when format fails", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "bad %d format", "not_a_number")
      -- should still emit with the raw message text
      assert.are.equal(1, #captured)
      assert.truthy(captured[1].message:find "bad")
    end)

    it("sets timestamp fields", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "ts test")
      assert.is_number(captured[1].timestamp)
      assert.is_string(captured[1].datetime)
    end)
  end)

  -- ──────────────────────────────
  -- Convenience methods
  -- ──────────────────────────────
  describe("convenience methods", function()
    it("debug() emits DEBUG level with prefix", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:debug("test %s", "val")
      assert.are.equal(1, #captured)
      assert.are.equal(levels.levels.DEBUG, captured[1].level)
      assert.truthy(captured[1].raw_message:find "^DEBUG: ")
    end)

    it("info() emits INFO level", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:info "hello"
      assert.are.equal(1, #captured)
      assert.are.equal(levels.levels.INFO, captured[1].level)
    end)

    it("warn() emits WARN level", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:warn("warning %d", 1)
      assert.are.equal(1, #captured)
      assert.are.equal(levels.levels.WARN, captured[1].level)
    end)

    it("error() emits ERROR level", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:error "fail"
      assert.are.equal(1, #captured)
      assert.are.equal(levels.levels.ERROR, captured[1].level)
    end)
  end)

  -- ──────────────────────────────
  -- _emit – sink error isolation
  -- ──────────────────────────────
  describe("_emit()", function()
    it("continues to next sink when one errors", function()
      local good_captured = {}
      local bad_sink = function()
        error "boom"
      end
      local good_sink = function(e)
        good_captured[#good_captured + 1] = e
      end
      local log = api.new("T", true, { bad_sink, good_sink })
      log:log("ERROR", "test")
      assert.are.equal(1, #good_captured)
    end)

    it("logs sink errors via wezterm.log_error", function()
      wezterm_mock._reset()
      local bad_sink = function()
        error "boom"
      end
      local log = api.new("T", true, { bad_sink })
      log:log("ERROR", "test")
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if call.fn == "log_error" and tostring(call.args[1]):find "Sink error" then
          found = true
        end
      end
      assert.is_true(found)
    end)
  end)

  -- ──────────────────────────────
  -- API table (module return)
  -- ──────────────────────────────
  describe("API module table", function()
    it("exposes levels module", function()
      assert.are.equal(levels, api.levels)
    end)

    it("exposes config module", function()
      assert.are.equal(config, api.config)
    end)

    it("exposes sinks registry", function()
      assert.is_table(api.sinks)
    end)

    it("setup() accepts table argument (function style)", function()
      api.setup { threshold = "INFO" }
      assert.are.equal("INFO", config.get().threshold)
    end)

    it("setup() accepts method-style call with self", function()
      api:setup { threshold = "ERROR" }
      assert.are.equal("ERROR", config.get().threshold)
    end)
  end)

  -- ──────────────────────────────
  -- prettify_args / stringify
  -- ──────────────────────────────
  describe("argument stringification", function()
    it("stringifies table arguments in format", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "val=%s", { key = 1 })
      assert.are.equal(1, #captured)
    end)

    it("stringifies nil arguments preserving position", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "a=%s b=%s", nil, "two")
      assert.are.equal(1, #captured)
      assert.truthy(captured[1].message:find "two")
    end)

    it("stringifies boolean arguments", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "flag=%s", true)
      assert.are.equal(1, #captured)
      assert.truthy(captured[1].message:find "true")
    end)

    it("stringifies userdata via tostring", function()
      local s = spy_sink()
      local log = api.new("T", true, { s })
      -- io.stdout is a userdata
      log:log("ERROR", "ud=%s", io.stdout)
      assert.are.equal(1, #captured)
      assert.truthy(captured[1].message:find "file")
    end)

    it("uses tostring fallback when wezterm.to_string is nil", function()
      local saved = wezterm_mock.to_string
      wezterm_mock.to_string = nil
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "v=%s", 42)
      assert.are.equal(1, #captured)
      assert.truthy(captured[1].message:find "42")
      wezterm_mock.to_string = saved
    end)
  end)

  -- ──────────────────────────────
  -- make_timestamp fallback
  -- ──────────────────────────────
  describe("timestamp fallback", function()
    it("falls back to os.time when wezterm.time is nil", function()
      local saved = wezterm_mock.time
      wezterm_mock.time = nil
      local s = spy_sink()
      local log = api.new("T", true, { s })
      log:log("ERROR", "fallback ts")
      assert.are.equal(1, #captured)
      assert.is_number(captured[1].timestamp)
      assert.is_string(captured[1].datetime)
      wezterm_mock.time = saved
    end)
  end)
end)
