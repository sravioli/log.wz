local wezterm_mock = require "wezterm"

-- ═══════════════════════════════════════════════════════════
-- MEMORY SINK
-- ═══════════════════════════════════════════════════════════
describe("log.sinks.memory", function()
  local memory

  before_each(function()
    -- Force a fresh require each time
    package.loaded["log.sinks.memory"] = nil
    memory = require "log.sinks.memory"
  end)

  local function make_event(overrides)
    local e = {
      timestamp = os.time(),
      datetime = "2025-01-01 00:00:00.000",
      level = 2,
      level_name = "WARN",
      tag = "Test",
      message = "[Test] hello",
      raw_message = "hello",
    }
    if overrides then
      for k, v in pairs(overrides) do
        e[k] = v
      end
    end
    return e
  end

  describe("constructor", function()
    it("creates a sink with default max_entries", function()
      local sink = memory()
      assert.are.equal(10000, sink.max_entries)
      assert.are.equal(0, #sink.entries)
    end)

    it("accepts custom max_entries", function()
      local sink = memory { max_entries = 5 }
      assert.are.equal(5, sink.max_entries)
    end)

    it("accepts max_entries = 0 for unlimited", function()
      local sink = memory { max_entries = 0 }
      assert.are.equal(0, sink.max_entries)
    end)
  end)

  describe("write()", function()
    it("stores an event", function()
      local sink = memory()
      sink:write(make_event())
      assert.are.equal(1, sink:count())
    end)

    it("evicts oldest entry when max_entries reached", function()
      local sink = memory { max_entries = 2 }
      sink:write(make_event { message = "first" })
      sink:write(make_event { message = "second" })
      sink:write(make_event { message = "third" })
      assert.are.equal(2, sink:count())
      assert.are.equal("second", sink.entries[1].message)
      assert.are.equal("third", sink.entries[2].message)
    end)

    it("does not evict when max_entries is 0", function()
      local sink = memory { max_entries = 0 }
      for i = 1, 100 do
        sink:write(make_event { message = tostring(i) })
      end
      assert.are.equal(100, sink:count())
    end)
  end)

  describe("__call()", function()
    it("is callable as a function (sink interface)", function()
      local sink = memory()
      sink(make_event())
      assert.are.equal(1, sink:count())
    end)
  end)

  describe("clear()", function()
    it("removes all entries", function()
      local sink = memory()
      sink:write(make_event())
      sink:write(make_event())
      sink:clear()
      assert.are.equal(0, sink:count())
    end)
  end)

  describe("get_entries()", function()
    it("returns a shallow copy", function()
      local sink = memory()
      sink:write(make_event { message = "a" })
      local entries = sink:get_entries()
      assert.are.equal(1, #entries)
      -- mutating the copy should not affect the sink
      entries[1] = nil
      assert.are.equal(1, sink:count())
    end)
  end)

  describe("count()", function()
    it("returns 0 for empty sink", function()
      local sink = memory()
      assert.are.equal(0, sink:count())
    end)

    it("returns correct count after writes", function()
      local sink = memory()
      sink:write(make_event())
      sink:write(make_event())
      assert.are.equal(2, sink:count())
    end)
  end)

  describe("to_string()", function()
    it("returns empty string for empty sink", function()
      local sink = memory()
      assert.are.equal("", sink:to_string())
    end)

    it("formats entries as [LEVEL] message lines", function()
      local sink = memory()
      sink:write(make_event { level_name = "ERROR", message = "[T] boom" })
      sink:write(make_event { level_name = "WARN", message = "[T] caution" })
      local str = sink:to_string()
      assert.truthy(str:find "%[ERROR%] %[T%] boom")
      assert.truthy(str:find "%[WARN%] %[T%] caution")
      -- lines separated by newline
      assert.truthy(str:find "\n")
    end)
  end)
end)

-- ═══════════════════════════════════════════════════════════
-- JSON SINK
-- ═══════════════════════════════════════════════════════════
describe("log.sinks.json", function()
  local json

  before_each(function()
    wezterm_mock._reset()
    package.loaded["log.sinks.json"] = nil
    json = require "log.sinks.json"
  end)

  local function make_event()
    return {
      timestamp = 1000,
      datetime = "2025-01-01 00:00:00.000",
      level = 2,
      level_name = "WARN",
      tag = "Test",
      message = "[Test] hello",
      raw_message = "hello",
    }
  end

  describe("encode()", function()
    it("returns a JSON string", function()
      local result = json.encode { key = "value" }
      assert.is_string(result)
      assert.truthy(result:find "key")
      assert.truthy(result:find "value")
    end)

    it("errors when serde is unavailable", function()
      local saved = wezterm_mock.serde
      wezterm_mock.serde = nil
      package.loaded["log.sinks.json"] = nil
      local j = require "log.sinks.json"
      assert.has_error(function()
        j.encode "test"
      end)
      wezterm_mock.serde = saved
    end)
  end)

  describe("decode()", function()
    it("returns a table", function()
      local result = json.decode "{}"
      assert.is_table(result)
    end)

    it("errors when serde is unavailable", function()
      local saved = wezterm_mock.serde
      wezterm_mock.serde = nil
      package.loaded["log.sinks.json"] = nil
      local j = require "log.sinks.json"
      assert.has_error(function()
        j.decode "{}"
      end)
      wezterm_mock.serde = saved
    end)
  end)

  describe("write()", function()
    it("logs encoded JSON via wezterm.log_info", function()
      json.write(make_event())
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if call.fn == "log_info" then
          found = true
        end
      end
      assert.is_true(found)
    end)

    it("logs error when encoding fails", function()
      -- Force encode to fail by breaking serde temporarily
      local saved_encode = wezterm_mock.serde.json_encode
      wezterm_mock.serde.json_encode = function()
        error "encode failure"
      end
      package.loaded["log.sinks.json"] = nil
      local j = require "log.sinks.json"
      j.write(make_event())
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if call.fn == "log_error" and tostring(call.args[1]):find "Failed to encode" then
          found = true
        end
      end
      assert.is_true(found)
      wezterm_mock.serde.json_encode = saved_encode
    end)
  end)

  describe("__call()", function()
    it("is callable as a sink function", function()
      json(make_event())
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if call.fn == "log_info" then
          found = true
        end
      end
      assert.is_true(found)
    end)
  end)
end)

-- ═══════════════════════════════════════════════════════════
-- WZ SINK (default WezTerm sink)
-- ═══════════════════════════════════════════════════════════
describe("log.sinks.wz", function()
  local wz_sink

  before_each(function()
    wezterm_mock._reset()
    package.loaded["log.sinks.wz"] = nil
    wz_sink = require "log.sinks.wz"
  end)

  it("calls log_info for DEBUG level", function()
    wz_sink { level = 0, message = "debug msg" }
    assert.are.equal("log_info", wezterm_mock._calls[1].fn)
  end)

  it("calls log_info for INFO level", function()
    wz_sink { level = 1, message = "info msg" }
    assert.are.equal("log_info", wezterm_mock._calls[1].fn)
  end)

  it("calls log_warn for WARN level", function()
    wz_sink { level = 2, message = "warn msg" }
    assert.are.equal("log_warn", wezterm_mock._calls[1].fn)
  end)

  it("calls log_error for ERROR level", function()
    wz_sink { level = 3, message = "error msg" }
    assert.are.equal("log_error", wezterm_mock._calls[1].fn)
  end)

  it("does nothing for unknown level", function()
    wz_sink { level = 99, message = "unknown" }
    assert.are.equal(0, #wezterm_mock._calls)
  end)
end)

-- ═══════════════════════════════════════════════════════════
-- FILE SINK
-- ═══════════════════════════════════════════════════════════
describe("log.sinks.file", function()
  local file_sink_mod
  local tmpdir = os.getenv "TEMP" or os.getenv "TMPDIR" or "/tmp"

  before_each(function()
    wezterm_mock._reset()
    package.loaded["log.sinks.file"] = nil
    package.loaded["log.sinks.json"] = nil
    file_sink_mod = require "log.sinks.file"
  end)

  local function make_event(overrides)
    local e = {
      timestamp = 1000,
      datetime = "2025-01-01 00:00:00.000",
      level = 2,
      level_name = "WARN",
      tag = "Test",
      message = "[Test] hello",
      raw_message = "hello",
    }
    if overrides then
      for k, v in pairs(overrides) do
        e[k] = v
      end
    end
    return e
  end

  local function tmp_file(name)
    return tmpdir .. package.config:sub(1, 1) .. name
  end

  local function cleanup(path)
    os.remove(path)
  end

  describe("constructor", function()
    it("creates a sink with default format=json", function()
      local sink = file_sink_mod { path = tmp_file "test_file_sink_default.log" }
      assert.are.equal("json", sink.format)
      cleanup(sink.path)
    end)

    it("accepts text format", function()
      local sink =
        file_sink_mod { path = tmp_file "test_file_sink_text.log", format = "text" }
      assert.are.equal("text", sink.format)
      cleanup(sink.path)
    end)

    it("accepts custom formatter", function()
      local fmt = function(event)
        return "custom:" .. event.message
      end
      local sink = file_sink_mod {
        path = tmp_file "test_file_sink_custom.log",
        formatter = fmt,
      }
      assert.are.equal(fmt, sink.formatter)
      cleanup(sink.path)
    end)

    it("resolves default path when none given", function()
      local sink = file_sink_mod()
      assert.is_string(sink.path)
      assert.truthy(#sink.path > 0)
    end)
  end)

  describe("serialize()", function()
    it("serializes text format", function()
      local sink = file_sink_mod { path = tmp_file "ser_text.log", format = "text" }
      local ok, payload = sink:serialize(make_event())
      assert.is_true(ok)
      assert.truthy(payload:find "WARN")
      assert.truthy(payload:find "%[Test%] hello")
      cleanup(sink.path)
    end)

    it("serializes json format", function()
      local sink = file_sink_mod { path = tmp_file "ser_json.log", format = "json" }
      local ok, payload = sink:serialize(make_event())
      assert.is_true(ok)
      assert.is_string(payload)
      cleanup(sink.path)
    end)

    it("uses custom formatter when provided", function()
      local fmt = function(e)
        return "CUSTOM:" .. e.tag
      end
      local sink = file_sink_mod {
        path = tmp_file "ser_custom.log",
        formatter = fmt,
      }
      local ok, payload = sink:serialize(make_event())
      assert.is_true(ok)
      assert.are.equal("CUSTOM:Test", payload)
      cleanup(sink.path)
    end)

    it("returns error when custom formatter throws", function()
      local fmt = function()
        error "bad"
      end
      local sink = file_sink_mod {
        path = tmp_file "ser_err.log",
        formatter = fmt,
      }
      local ok, err = sink:serialize(make_event())
      assert.is_false(ok)
      assert.truthy(err:find "bad")
      cleanup(sink.path)
    end)

    it("returns error when custom formatter returns non-string", function()
      local fmt = function()
        return 42
      end
      local sink = file_sink_mod {
        path = tmp_file "ser_nonstr.log",
        formatter = fmt,
      }
      local ok, err = sink:serialize(make_event())
      assert.is_false(ok)
      assert.truthy(err:find "must return a string")
      cleanup(sink.path)
    end)
  end)

  describe("append()", function()
    it("writes payload to file", function()
      local path = tmp_file "append_test.log"
      cleanup(path)
      local sink = file_sink_mod { path = path, format = "text" }
      local ok = sink:append "line one"
      assert.is_true(ok)
      local f = io.open(path, "r")
      local content = f:read "*a"
      f:close()
      assert.truthy(content:find "line one")
      cleanup(path)
    end)

    it("appends multiple payloads", function()
      local path = tmp_file "append_multi.log"
      cleanup(path)
      local sink = file_sink_mod { path = path, format = "text" }
      sink:append "line 1"
      sink:append "line 2"
      local f = io.open(path, "r")
      local content = f:read "*a"
      f:close()
      assert.truthy(content:find "line 1")
      assert.truthy(content:find "line 2")
      cleanup(path)
    end)
  end)

  describe("write() and __call()", function()
    it("writes a complete event to file", function()
      local path = tmp_file "write_test.log"
      cleanup(path)
      local sink = file_sink_mod { path = path, format = "text" }
      sink:write(make_event())
      local f = io.open(path, "r")
      local content = f:read "*a"
      f:close()
      assert.truthy(content:find "WARN")
      cleanup(path)
    end)

    it("is callable as a sink function (__call)", function()
      local path = tmp_file "call_test.log"
      cleanup(path)
      local sink = file_sink_mod { path = path, format = "text" }
      sink(make_event())
      local f = io.open(path, "r")
      local content = f:read "*a"
      f:close()
      assert.truthy(content:find "WARN")
      cleanup(path)
    end)

    it("logs error via wezterm when serialization fails", function()
      wezterm_mock._reset()
      local sink = file_sink_mod {
        path = tmp_file "write_err.log",
        formatter = function()
          error "ser fail"
        end,
      }
      sink:write(make_event())
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if
          call.fn == "log_error" and tostring(call.args[1]):find "Failed to serialize"
        then
          found = true
        end
      end
      assert.is_true(found)
    end)
  end)

  describe("config_dir relocation", function()
    it("relocates path inside config_dir", function()
      local saved_dir = wezterm_mock.config_dir
      wezterm_mock.config_dir = tmpdir .. package.config:sub(1, 1) .. "fake_config"
      package.loaded["log.sinks.file"] = nil
      local fsm = require "log.sinks.file"
      local inside_path = wezterm_mock.config_dir .. package.config:sub(1, 1) .. "my.log"
      local sink = fsm { path = inside_path }
      -- Should NOT be inside config dir anymore
      local norm_cfg = wezterm_mock.config_dir:gsub("\\", "/"):lower()
      if norm_cfg:sub(-1) ~= "/" then
        norm_cfg = norm_cfg .. "/"
      end
      local norm_sink = sink.path:gsub("\\", "/"):lower()
      assert.is_false(norm_sink:sub(1, #norm_cfg) == norm_cfg)
      wezterm_mock.config_dir = saved_dir
    end)

    it("returns false from is_inside_config_dir when config_dir is nil", function()
      local saved_dir = wezterm_mock.config_dir
      wezterm_mock.config_dir = nil
      package.loaded["log.sinks.file"] = nil
      local fsm = require "log.sinks.file"
      local path = tmp_file "noconfig.log"
      local sink = fsm { path = path }
      -- Path should be unchanged since config_dir is nil
      assert.are.equal(path, sink.path)
      wezterm_mock.config_dir = saved_dir
      cleanup(path)
    end)
  end)

  describe("json serialization errors in file sink", function()
    it("returns error when json module fails to load", function()
      -- Poison the json module so get_json_module returns nil
      local saved_json = package.loaded["log.sinks.json"]
      local saved_preload = package.preload["log.sinks.json"]
      package.loaded["log.sinks.json"] = nil
      package.preload["log.sinks.json"] = function()
        error "no json"
      end
      package.loaded["log.sinks.file"] = nil
      local fsm = require "log.sinks.file"
      local sink = fsm { path = tmp_file "json_fail.log", format = "json" }
      local ok, err = sink:serialize(make_event())
      assert.is_false(ok)
      assert.truthy(err:find "unable to load json sink")
      -- Restore
      package.preload["log.sinks.json"] = saved_preload
      package.loaded["log.sinks.json"] = saved_json
      cleanup(sink.path)
    end)

    it("returns error when json.encode fails", function()
      -- Use a json module that has encode throw
      package.loaded["log.sinks.json"] = nil
      package.loaded["log.sinks.file"] = nil
      local real_encode = wezterm_mock.serde.json_encode
      wezterm_mock.serde.json_encode = function()
        error "encode boom"
      end
      local fsm = require "log.sinks.file"
      local sink = fsm { path = tmp_file "encode_fail.log", format = "json" }
      local ok, err = sink:serialize(make_event())
      assert.is_false(ok)
      assert.truthy(err:find "encode boom")
      wezterm_mock.serde.json_encode = real_encode
      cleanup(sink.path)
    end)
  end)

  describe("file sink get_json_module cache hit", function()
    it("returns cached json module on second call", function()
      package.loaded["log.sinks.file"] = nil
      package.loaded["log.sinks.json"] = nil
      local fsm = require "log.sinks.file"
      local sink = fsm { path = tmp_file "cache_json.log", format = "json" }
      -- First serialize loads json module
      local ok1, _ = sink:serialize(make_event())
      assert.is_true(ok1)
      -- Second serialize should hit cache
      local ok2, _ = sink:serialize(make_event())
      assert.is_true(ok2)
      cleanup(sink.path)
    end)
  end)

  describe("write() error on append failure", function()
    it("logs error via wezterm when append fails", function()
      wezterm_mock._reset()
      package.loaded["log.sinks.file"] = nil
      local fsm = require "log.sinks.file"
      -- Use a path pointing into a nonexistent directory to force io.open failure
      local bad_path = tmp_file(
        "nonexistent_dir_xyz"
          .. package.config:sub(1, 1)
          .. "sub"
          .. package.config:sub(1, 1)
          .. "fail.log"
      )
      local sink = fsm { path = bad_path, format = "text" }
      sink:write(make_event())
      local found = false
      for _, call in ipairs(wezterm_mock._calls) do
        if call.fn == "log_error" and tostring(call.args[1]):find "Failed to append" then
          found = true
        end
      end
      assert.is_true(found)
    end)
  end)
end)

-- ═══════════════════════════════════════════════════════════
-- SINKS INIT (lazy-loader / fallbacks)
-- ═══════════════════════════════════════════════════════════
describe("log.sinks (init)", function()
  before_each(function()
    wezterm_mock._reset()
    -- Clear cached sinks so lazy-loading re-triggers
    package.loaded["log.sinks"] = nil
    package.loaded["log.sinks.wz"] = nil
    package.loaded["log.sinks.json"] = nil
    package.loaded["log.sinks.memory"] = nil
    package.loaded["log.sinks.file"] = nil
  end)

  it("lazy-loads wz sink", function()
    local sinks = require "log.sinks"
    assert.is_function(sinks.wz)
  end)

  it("lazy-loads json sink", function()
    local sinks = require "log.sinks"
    assert.is_table(sinks.json)
    assert.is_function(sinks.json.encode)
  end)

  it("lazy-loads memory sink (callable constructor)", function()
    local sinks = require "log.sinks"
    local mem = sinks.memory()
    assert.is_table(mem)
    assert.are.equal(0, mem:count())
  end)

  it("lazy-loads file sink (callable constructor)", function()
    local sinks = require "log.sinks"
    local f = sinks.file()
    assert.is_table(f)
    assert.is_string(f.path)
  end)

  it("returns fallback for unknown sink module", function()
    local sinks = require "log.sinks"
    local unknown = sinks.nonexistent
    -- Should be a no-op function from the fallback
    assert.is_function(unknown)
    -- Calling it should not error
    assert.has_no.errors(function()
      unknown {}
    end)
  end)

  -- ── Fallback sinks when real modules fail to load ──
  describe("fallback sinks", function()
    local function poison_module(name)
      package.loaded[name] = nil
      package.preload[name] = function()
        error "forced load failure"
      end
    end

    local function unpoison_module(name)
      package.preload[name] = nil
      package.loaded[name] = nil
    end

    it("returns fallback json sink when json module fails", function()
      poison_module "log.sinks.json"
      local sinks = require "log.sinks"
      local j = sinks.json
      assert.is_table(j)
      assert.are.equal("{}", j.encode "x")
      assert.is_table(j.decode "{}")
      assert.is_nil(j.write {})
      assert.is_nil(j {})
      unpoison_module "log.sinks.json"
    end)

    it("returns fallback file sink when file module fails", function()
      poison_module "log.sinks.file"
      local sinks = require "log.sinks"
      local f = sinks.file
      assert.is_table(f)
      local instance = f()
      assert.is_table(instance)
      assert.are.equal(".", instance.path)
      assert.are.equal("json", instance.format)
      -- write and __call should not error
      instance:write {}
      instance {}
      unpoison_module "log.sinks.file"
    end)

    it("returns fallback memory sink when memory module fails", function()
      poison_module "log.sinks.memory"
      local sinks = require "log.sinks"
      local m = sinks.memory
      assert.is_table(m)
      local instance = m()
      assert.is_table(instance)
      assert.are.equal(0, instance.max_entries)
      instance:write {}
      instance:clear()
      assert.is_table(instance:get_entries())
      assert.are.equal(0, instance:count())
      assert.are.equal("", instance:to_string())
      instance {}
      unpoison_module "log.sinks.memory"
    end)
  end)
end)
