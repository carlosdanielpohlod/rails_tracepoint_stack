# TODO: Move to a loader file
require "rails_tracepoint_stack/logger"
require "rails_tracepoint_stack/trace_filter"
require "rails_tracepoint_stack/trace"
require "rails_tracepoint_stack/log_formatter"

module RailsTracepointStack
  class TracerBase
    include RailsTracepointStack::TraceFilter
    extend Forwardable
 
    def_delegators :@tracer, :enable, :disable

    def initialize
      generate_tracer
    end
  end
end
