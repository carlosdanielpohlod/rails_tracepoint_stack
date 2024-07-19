# Changelog

## 0.2.1

**Changes:**

- Update the ENV enable to be more semantic
- Add the VERSION constant module
- Sorted the files inside of gemspec
- Support to use Rails.env as default for the default log file

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
