# Changelog

## 0.3.2

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
