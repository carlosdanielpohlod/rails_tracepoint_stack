require 'rails_tracepoint_stack/logger'
require 'rails_tracepoint_stack/trace_filter'

module RailsTracepointStack
  class Tracer
    # TODO: Tracer.new shoud return the tracer. Is weird to call Tracer.new.tracer
    def tracer
      @trace ||= TracePoint.new(:call) do |tp|
        next if RailsTracepointStack::TraceFilter.ignore_trace?(trace: tp)

        params = fetch_params(tp)

        # TODO: Use proper OO
        message = RailsTracepointStack::LogFormatter.message tp, params
        RailsTracepointStack::Logger.log message
      end
    end

    private
    attr_reader :gem_paths, :ruby_lib_path

    # TODO: Extract this fetch from here
    def fetch_params(tp)
      tp.binding.local_variables.map do |var|
        [var, tp.binding.local_variable_get(var)]
      end.to_h
    end
  end
end
