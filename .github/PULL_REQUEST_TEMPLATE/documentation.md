### Summary

Describe the log.wz documentation change.

### Documentation Changed

List the README, examples, contributing guide, issue templates, pull request
templates, or annotation docs changed by this pull request.

### Reader Impact

Explain who benefits from this documentation change:

- Users configuring logger levels and sinks.
- Plugin authors integrating log.wz.
- Contributors changing logger internals.

### Examples Touched

```lua
-- logger, sink, or setup example changed by this pull request
```

### Behavior Change

- [ ] Documentation only
- [ ] Documents an existing behavior
- [ ] Documents a new behavior

If this documents a new behavior, link to the implementation pull request or
commit.

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

