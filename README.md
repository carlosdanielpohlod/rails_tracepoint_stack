## Install

```bash
gem install rails_tracepoint_stack
```

set env 
```bash
RAILS_TRACEPOINT_STACK_ENABLED=true
``` 
if you wanna enable it globally on your Rails app

## Description

This project aims to create a logger for method calls in Ruby <img src="https://i.pinimg.com/originals/3f/f8/de/3ff8de311854ae91dae1919f7806ff86.gif" width="40px" heigth="40px">, excluding methods from gems, internal classes, etc.

By utilizing Ruby's `TracePoint` functionality, it allows monitoring and displaying the methods called during the application's execution, filtering to show only the methods defined in the application's own code.

## Usage 

Global use:

By using the global tracing, just configuring `RAILS_TRACEPOINT_STACK` as true, you can have a sample scenario and output as:

```ruby
module Foo
  def puts_message(message)
    puts message
  end
end

class Bar
  include Foo

  def initialize(message:)
    @message = message
  end

  def perform
    puts_message(message)
  end
end
```

then

```ruby
Bar.new(message: "Hello World").call
```

will produce an output as:

```json
called: Bar#initialize in COMPLETE_PATH_TO_YOUR_FILE/app/services/bar.rb:METHOD_LINE with params: {:message=>"Hello World"}
called: Bar#perform in COMPLETE_PATH_TO_YOUR_FILE/app/services/bar.rb:METHOD_LINE with params: {}
called: Foo#puts_message in COMPLETE_PATH_TO_YOUR_FILE/app/services/foo:METHOD_LINE with params: {:message=>"Hello World"}
```
**Enabling Locally with .enable_trace**

You can also enable the tracer locally (even with `RAILS_TRACEPOINT_STACK` not defined) by passing a block of code to be traced:

```ruby
class Bar
  include Foo

  def initialize(message:)
    @message = message
  end

  def perform
    RailsTracepointStack.enable_trace do
      puts_message(@message)
    end
  end
end
```
wich will produce a similar result

## Configuration

You can also implement custom configuration for `RailsTracepointStack` by passing your custom configurations as follows:

| Configuration     | Description                                                                                   |
|-------------------|-----------------------------------------------------------------------------------------------|
| `ignore_patterns` | Pass a regex pattern to filter (ignore) matched traces. Example: `/services\/foo.rb/`         |
| `logger`          | Pass your custom logger. Example: `Rails.logger`. If not used, logs are saved in `log/rails_tracepoint_stack.log`. |
| `log_format`      | Inform what kind of format you wanna to use, text (default), of json                          |

Complete example:

```ruby
# config/initializers/rails_tracepoint_stack.rb

RailsTracepointStack.configure do |config|
  config.ignore_patterns << /services\/foo.rb/
  config.logger = YourLogger
  config.log_format = :text
end
