## Install

```
gem install rails_tracepoint_stack
```
## Description

This project aims to create a logger for method calls in Ruby <img src="https://i.pinimg.com/originals/3f/f8/de/3ff8de311854ae91dae1919f7806ff86.gif" width="40px" heigth="40px">, excluding methods from gems, internal classes, etc. 
By utilizing Ruby's `TracePoint` functionality, it allows monitoring and displaying the methods called during the application's execution, filtering to 
show only the methods defined in the application's own code.

## Usage in Rails

To use this script in a Rails project, simply add it to an initializer. Create a file in `config/initializers`, for example `tracepoint_logger.rb`, and paste the code there.

## Ouput
Sample scenario and output:
```
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
and
```
Bar.new(message: "Hello World").call
```
will produce an output as:
```
called: Bar#initialize in COMPLETE_PATH_TO_YOUR_FILE/app/services/bar.rb:METHOD_LINE with params: {:message=>"Hello World"}
called: Bar#call in COMPLETE_PATH_TO_YOUR_FILE/app/services/bar.rb:METHOD_LINE with params: {}
called: Foo#puts_message in COMPLETE_PATH_TO_YOUR_FILE/app/services/foo:METHOD_LINE with params: {:message=>"Hello World"}

```
