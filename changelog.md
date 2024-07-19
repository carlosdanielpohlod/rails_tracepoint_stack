# Changelog

## 0.2.0

**Changes:**

- Add configuration of custom log patterns to be ignored.
- Add Rspec and Rake.

## 0.1.4

**Changes:**

- Ignore logs containing `gems/bundler`.
- Require ruby >= 3.0.

**Breaking Changes:**

- To enable logs catch, it is necessary to set `RAILS_TRACEPOINT_STACK` as `true`.
