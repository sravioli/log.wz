require "wezterm"
local levels = require "log.levels"

describe("log.levels", function()
  describe("levels enum", function()
    it("defines DEBUG as 0", function()
      assert.are.equal(0, levels.levels.DEBUG)
    end)

    it("defines INFO as 1", function()
      assert.are.equal(1, levels.levels.INFO)
    end)

    it("defines WARN as 2", function()
      assert.are.equal(2, levels.levels.WARN)
    end)

    it("defines ERROR as 3", function()
      assert.are.equal(3, levels.levels.ERROR)
    end)
  end)

  describe("names", function()
    it("maps 0 to DEBUG", function()
      assert.are.equal("DEBUG", levels.names[0])
    end)

    it("maps 1 to INFO", function()
      assert.are.equal("INFO", levels.names[1])
    end)

    it("maps 2 to WARN", function()
      assert.are.equal("WARN", levels.names[2])
    end)

    it("maps 3 to ERROR", function()
      assert.are.equal("ERROR", levels.names[3])
    end)
  end)

  describe("normalize()", function()
    it("normalizes lowercase string to level integer", function()
      assert.are.equal(0, levels.normalize "debug")
      assert.are.equal(1, levels.normalize "info")
      assert.are.equal(2, levels.normalize "warn")
      assert.are.equal(3, levels.normalize "error")
    end)

    it("normalizes uppercase string to level integer", function()
      assert.are.equal(0, levels.normalize "DEBUG")
      assert.are.equal(1, levels.normalize "INFO")
      assert.are.equal(2, levels.normalize "WARN")
      assert.are.equal(3, levels.normalize "ERROR")
    end)

    it("normalizes mixed-case string", function()
      assert.are.equal(2, levels.normalize "Warn")
    end)

    it("returns numeric level as-is", function()
      assert.are.equal(0, levels.normalize(0))
      assert.are.equal(3, levels.normalize(3))
    end)

    it("returns nil for unrecognised string", function()
      assert.is_nil(levels.normalize "TRACE")
      assert.is_nil(levels.normalize "")
    end)

    it("returns nil for non-number non-string types", function()
      assert.is_nil(levels.normalize(true))
      assert.is_nil(levels.normalize(nil))
      assert.is_nil(levels.normalize {})
    end)

    it("passes through arbitrary numeric values", function()
      assert.are.equal(99, levels.normalize(99))
      assert.are.equal(-1, levels.normalize(-1))
    end)

    it("returns nil for function type", function()
      assert.is_nil(levels.normalize(function() end))
    end)
  end)
end)
