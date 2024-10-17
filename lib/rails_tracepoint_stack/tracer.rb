require "rails_tracepoint_stack/tracer_base"

module RailsTracepointStack
  class Tracer < RailsTracepointStack::TracerBase
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
