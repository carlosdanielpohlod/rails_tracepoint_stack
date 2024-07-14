## Description

This project aims to create a logger for method calls in Ruby <img src="https://i.pinimg.com/originals/3f/f8/de/3ff8de311854ae91dae1919f7806ff86.gif" width="40px" heigth="40px">, excluding methods from gems, internal classes, etc. 
By utilizing Ruby's `TracePoint` functionality, it allows monitoring and displaying the methods called during the application's execution, filtering to 
show only the methods defined in the application's own code.

## Usage in Rails

To use this script in a Rails project, simply add it to an initializer. Create a file in `config/initializers`, for example `tracepoint_logger.rb`, and paste the code there.
