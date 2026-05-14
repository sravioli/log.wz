### Summary

Describe the bug fixed in log.wz and the user-visible logging behavior that
changed.

### Reproduction

Provide the smallest setup that reproduced the issue.

```lua
-- logger setup or logging call that reproduced the bug
```

### Root Cause

Explain why level resolution, sink routing, formatting, configuration, or
WezTerm logging integration was wrong.

### Fix

Describe the implementation change and why it fixes the problem.

### Regression Test

Describe the regression test added or updated.

### Compatibility Impact

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this changes behavior intentionally, explain why the new behavior is correct.

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

