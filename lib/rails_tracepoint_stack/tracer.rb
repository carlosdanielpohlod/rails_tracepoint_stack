# TODO: Move to a loader file
require "rails_tracepoint_stack/logger"
require "rails_tracepoint_stack/trace_filter"
require "rails_tracepoint_stack/trace"
require "rails_tracepoint_stack/log_formatter"
require "rails_tracepoint_stack/sink/log"

module RailsTracepointStack
  class Tracer
    include RailsTracepointStack::TraceFilter
    extend Forwardable

    DEFAULT_EVENTS = [:call].freeze

    def_delegators :@tracer, :enable, :disable

    def initialize(sink: RailsTracepointStack::Sink::Log.new, events: DEFAULT_EVENTS)
      @sink = sink
      @events = events
      generate_tracer
    end

    private

    def generate_tracer
      @tracer ||= TracePoint.new(*@events) do |tracepoint|
        trace = RailsTracepointStack::Trace.new(trace_point: tracepoint)

        next if ignore_trace?(trace: trace)

        @sink.record(trace)
      end
    end
  end
end
