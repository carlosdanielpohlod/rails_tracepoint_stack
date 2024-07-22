module RailsTracepointStack
  class Tracer
    # TODO: Tracer.new shoud return the tracer. Is weird to call Tracer.new.tracer
    def tracer
      @tracer ||= TracePoint.new(:call) do |tracepoint|
        trace = RailsTracepointStack::Trace.new(trace_point: tracepoint)

        next if RailsTracepointStack::TraceFilter.ignore_trace?(trace: trace)

        # TODO: Use proper OO
        message = RailsTracepointStack::LogFormatter.message trace
        RailsTracepointStack::Logger.log message 
      end
    end
  end
end
