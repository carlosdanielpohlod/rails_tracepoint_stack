# Changelog

## 0.4.0

**Features**

- `RailsTracepointStack.capture` traces a block and returns the traces in
  memory, with no env var, log file or restart involved
- Traces now carry return values and raised exceptions, not just calls and params
- Each trace knows its call depth, so a session renders as a call tree
- `session.to_tree`, `session.as_json` and `session.summary` render a capture
- Captures are bounded by `max_depth`, `max_traces`, `max_string_length` and
  `max_collection_size`, and report `truncated?` when a limit cut them short
- Captures watch only the calling thread by default; `threads: :all` opts out
- `rails g rails_tracepoint_stack:install` writes an agent skill into the app,
  so AI coding agents know when and how to trace it

**BugFix**

- Params reported every local the method body declared, not just the arguments
  it received, so unassigned locals showed up as arguments passed as nil.
  `TracePoint#parameters` now decides what is read from the binding
- `GemPath` referenced `Bundler` without requiring it, raising `NameError` on
  the first trace outside a bundle
- A raise coming out of a C method landed one level too deep in the tree

**Changes**

- The tracer writes to a sink; the default one keeps the previous logging
  behaviour, so global tracing is unchanged
- Class methods render as `Foo.bar` rather than `#<Class:Foo>#bar`
- Compiled templates render as `render app/views/…` with their locals, instead
  of the generated method name and the rendering internals
- An empty capture reports how many traces the filters dropped, so "nothing
  ran" is distinguishable from "nothing of yours ran"
- Serialized string values are frozen copies, so a snapshot no longer follows
  later mutations of the traced object

## 0.3.5

**BugFix**

- Sanitize traced params before formatting so JSON logging does not overflow on recursive or problematic objects [Issue #37](https://github.com/carlosdanielpohlod/rails_tracepoint_stack/issues/37)
- Stabilize text log param rendering across Ruby versions

## 0.3.4

**Changes**

- Fix flaky tests by @danielmbrasil [PR #27](https://github.com/carlosdanielpohlod/rails_tracepoint_stack/pull/27)

- Huge refactor of filters class, separating in modules by filter type [PR #18](https://github.com/carlosdanielpohlod/rails_tracepoint_stack/pull/18)

- Some other code refactors

## 0.3.3

**Changes**

- Add autoload of all lib files on test_helper
- Fix some tests

**BugFix**

- Fixed the Configuration module not loading the default value for the configuration attributes

## 0.3.1

**Changes:**

- Add the ability to include the external sources to the log using `config.log_external_sources = true`

## 0.3.0

**Changes:**

- Refactor classes, formatting a trace using a value object class `RailsTracepointStack::Trace`
- include configuration `log_format` option, allowing choose an output as `text` or `json`
- Include configuration `file_path_to_filter_patterns`, allowing filter traces only when the origin file path matches a pattern
- Improve test coverage

## 0.2.1

**Changes:**

- Update the ENV enable to be more semantic
- Add the VERSION constant module
- Sorted the files inside of gemspec
- Fix the depencies on the gemspec
- Add the "log_format" configuration support for text and json formats

## 0.2.0

**Changes:**

- Refactor by separating Logger and Filter into their own classes.

- Introduce `RailsTracepointStack.configure`, which allows ignoring traces with a custom pattern and customizing the logs output. Example:

```ruby
RailsTracepointStack.configure do |config|
  config.ignore_patterns << /services\/foo.rb/
  config.logger = YourLogger
end
```

The default log destination is a file located on `log/rails_tracepoint_stack.log`

- Add The possibility of enable the tracer locally, by calling:

```ruby
class Foo
  def bar
    RailsTracepointStack.enable_trace do
      p "your code"
    end
  end
end
```

- Add Rspec and Rake development dependencies, and add partial test coverage.

## 0.1.4

**Changes:**

- Ignore logs containing `gems/bundler`.
- Require ruby >= 3.0.

**Breaking Changes:**

- To enable logs catch, it is necessary to set `RAILS_TRACEPOINT_STACK` as `true`.
