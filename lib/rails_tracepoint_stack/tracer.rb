# TODO: Move to a loader file
require "rails_tracepoint_stack/logger"
require "rails_tracepoint_stack/trace_filter"
require "rails_tracepoint_stack/trace"
require "rails_tracepoint_stack/log_formatter"
require "rails_tracepoint_stack/sink/log"
require "rails_tracepoint_stack/depth_tracker"

module RailsTracepointStack
  class Tracer
    include RailsTracepointStack::TraceFilter
    extend Forwardable

    DEFAULT_EVENTS = [:call].freeze

    def_delegators :@tracer, :enable, :disable

    # How many traces the filters dropped. A capture that keeps nothing is
    # ambiguous on its own: this tells the difference between code that never
    # ran and code that ran entirely inside gems.
    attr_reader :filtered_count

    # A nil thread watches every thread in the process, which is what the
    # global tracer wants. Passing one confines tracing to it, so a capture
    # running inside a threaded server does not pick up other requests.
    def initialize(sink: RailsTracepointStack::Sink::Log.new, events: DEFAULT_EVENTS, thread: nil)
      @sink = sink
      @events = events
      @thread = thread
      @filtered_count = 0
      generate_tracer
    end

    private

    def generate_tracer
      @tracer ||= TracePoint.new(*@events) do |tracepoint|
        next if out_of_scope_thread?

        trace = RailsTracepointStack::Trace.new(trace_point: tracepoint)

        if ignore_trace?(trace: trace)
          @filtered_count += 1
          next
        end

        trace.depth = depth_for(trace)
        @sink.record(trace)
      end
    end

    def out_of_scope_thread?
      !@thread.nil? && Thread.current != @thread
    end

    # Only kept traces pay for reading the stack position, so the cost stays
    # proportional to the app code being traced rather than to everything the
    # VM runs underneath it.
    def depth_for(trace)
      tracker = depth_tracker
      raw_position = raw_stack_position

      case trace.kind
      when :call then tracker.enter(raw_position)
      when :return then tracker.leave(raw_position)
      when :raise then tracker.raised(raw_position)
      end
    end

    def raw_stack_position
      caller_locations(1)&.length || 0
    end

    def depth_tracker
      Thread.current[depth_tracker_key] ||= RailsTracepointStack::DepthTracker.new
    end

    def depth_tracker_key
      @depth_tracker_key ||= :"rails_tracepoint_stack_depth_#{object_id}"
    end
  end
end
