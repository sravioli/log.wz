require "wezterm"
local config = require "log.config"

describe("log.config", function()
  -- Reset config to defaults before every test
  before_each(function()
    config.setup { enabled = true, threshold = "WARN", sinks = { default_enabled = true } }
  end)

  describe("get()", function()
    it("returns the default config", function()
      local c = config.get()
      assert.are.equal(true, c.enabled)
      assert.are.equal("WARN", c.threshold)
      assert.are.equal(true, c.sinks.default_enabled)
    end)

    it("returns the same reference on consecutive calls", function()
      assert.are.equal(config.get(), config.get())
    end)
  end)

  describe("setup()", function()
    it("overrides enabled flag", function()
      config.setup { enabled = false }
      assert.are.equal(false, config.get().enabled)
    end)

    it("overrides threshold", function()
      config.setup { threshold = "DEBUG" }
      assert.are.equal("DEBUG", config.get().threshold)
    end)

    it("overrides threshold with integer", function()
      config.setup { threshold = 0 }
      assert.are.equal(0, config.get().threshold)
    end)

    it("overrides sinks.default_enabled", function()
      config.setup { sinks = { default_enabled = false } }
      assert.are.equal(false, config.get().sinks.default_enabled)
    end)

    it("ignores unknown top-level keys", function()
      config.setup { foo = "bar" }
      local c = config.get()
      assert.is_nil(c.foo)
    end)

    it("ignores unknown sinks keys", function()
      config.setup { sinks = { unknown_key = true } }
      local c = config.get()
      assert.is_nil(c.sinks.unknown_key)
    end)

    it("is a no-op when called with nil", function()
      config.setup(nil)
      assert.are.equal(true, config.get().enabled)
    end)

    it("is a no-op when called with non-table", function()
      config.setup "string"
      assert.are.equal(true, config.get().enabled)
      config.setup(42)
      assert.are.equal(true, config.get().enabled)
    end)

    it("preserves existing values for keys not in overrides", function()
      config.setup { threshold = "DEBUG" }
      local c = config.get()
      assert.are.equal(true, c.enabled)
      assert.are.equal(true, c.sinks.default_enabled)
    end)

    it("handles sinks as non-table gracefully", function()
      config.setup { sinks = "invalid" }
      -- sinks subtable should be unchanged
      assert.are.equal(true, config.get().sinks.default_enabled)
    end)

    it("accumulates multiple sequential overrides", function()
      config.setup { threshold = "DEBUG" }
      config.setup { enabled = false }
      local c = config.get()
      assert.are.equal("DEBUG", c.threshold)
      assert.are.equal(false, c.enabled)
      assert.are.equal(true, c.sinks.default_enabled)
    end)

    it("overrides enabled with false then back to true", function()
      config.setup { enabled = false }
      assert.are.equal(false, config.get().enabled)
      config.setup { enabled = true }
      assert.are.equal(true, config.get().enabled)
    end)

    it("accepts empty table without error", function()
      config.setup {}
      assert.are.equal(true, config.get().enabled)
    end)

    it("does not replace sinks table reference", function()
      local ref = config.get().sinks
      config.setup { sinks = { default_enabled = false } }
      assert.are.equal(ref, config.get().sinks)
    end)
  end)
end)
