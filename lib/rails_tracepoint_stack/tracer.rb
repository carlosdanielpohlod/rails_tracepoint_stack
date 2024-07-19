require 'rails_tracepoint_stack/logger'
require 'rails_tracepoint_stack/trace_filter'

module RailsTracepointStack
  class Tracer
    def tracer
      @trace ||= TracePoint.new(:call) do |tp|
        next if RailsTracepointStack::TraceFilter.ignore_trace?(trace: tp)

        params = fetch_params(tp)
        
        RailsTracepointStack::Logger.log "called: #{tp.defined_class}##{tp.method_id} in #{tp.path}:#{tp.lineno} with params: #{params}"
      end
    end

    private
    attr_reader :gem_paths, :ruby_lib_path

    def fetch_params(tp)
      tp.binding.local_variables.map { |var|
        [var, tp.binding.local_variable_get(var)]
      }.to_h
    end
  end
end
