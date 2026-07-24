require "rails_tracepoint_stack/logger"
require "rails_tracepoint_stack/log_formatter"

module RailsTracepointStack
  module Sink
    # Formats each trace and writes it out, which is what the gem has always
    # done. Kept as the default so enabling the tracer globally behaves the
    # same as before sinks existed.
    class Log
      def record(trace)
        RailsTracepointStack::Logger.log(
          RailsTracepointStack::LogFormatter.message(trace)
        )
      end
    end
  end
end
