require 'rails_tracepoint_stack/logger'
require 'rails_tracepoint_stack/trace_filter'

module RailsTracepointStack
  class Tracer
    # TODO: Tracer.new shoud return the tracer. Is weird to call Tracer.new.tracer
    def tracer
      @trace ||= TracePoint.new(:call) do |tracepoint|
        next if RailsTracepointStack::TraceFilter.ignore_trace?(trace: tracepoint)

        
        trace = RailsTracepointStack::Trace.new(tracepoint: tracepoint)

        # TODO: Use proper OO
        message = RailsTracepointStack::LogFormatter.message tp, params
        RailsTracepointStack::Logger.log message
      end
    end

    private
    attr_reader :gem_paths, :ruby_lib_path

    
  end
end
