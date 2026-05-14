### Summary

Describe the new log.wz feature and the user-facing logging workflow it enables.

### Motivation

Explain why this belongs in log.wz. Focus on logger setup, levels, sinks,
formatting, diagnostics, or WezTerm logging integration.

### API Sketch

```lua
-- show intended logger, sink, level, or setup usage
```

### Behavior

Describe how the feature behaves, including default options, sink output,
threshold behavior, message formatting, and failure cases.

### Compatibility

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this is potentially breaking or breaking, explain the migration path.

### Tests

Describe the tests added or updated for this behavior.

### Documentation

Describe the README, examples, annotation, or template changes made for this
feature.

### Checklist

- [ ] The change is scoped to log.wz.
- [ ] Public API changes are documented, if applicable.
- [ ] Level, sink, formatting, or logger behavior is covered by tests, if applicable.
- [ ] Existing sink configuration remains compatible.
- [ ] Required checks pass:
  - [ ] `busted --verbose`
  - [ ] `luacheck .`
  - [ ] `stylua --check .`
  - [ ] `selene --display-style=quiet .`

