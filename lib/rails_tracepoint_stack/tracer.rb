# TODO: Move to a loader file
require "rails_tracepoint_stack/logger"
require "rails_tracepoint_stack/trace_filter"
require "rails_tracepoint_stack/trace"
require "rails_tracepoint_stack/log_formatter"

module RailsTracepointStack
  class Tracer
    include RailsTracepointStack::TraceFilter
    extend Forwardable
 
    def_delegators :@tracer, :enable, :disable

    def initialize
      generate_tracer
    end

    private

    def generate_tracer
      @tracer ||= TracePoint.new(:call) do |tracepoint|
        trace = RailsTracepointStack::Trace.new(trace_point: tracepoint)

        next if ignore_trace?(trace: trace)

        # TODO: Use proper OO
        message = RailsTracepointStack::LogFormatter.message trace
        RailsTracepointStack::Logger.log message
      end
    end
  end
end
