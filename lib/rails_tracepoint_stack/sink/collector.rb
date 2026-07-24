require "rails_tracepoint_stack/limits"
require "rails_tracepoint_stack/log_formatter"
require "rails_tracepoint_stack/trace_record"
require "rails_tracepoint_stack/trace_session"
require "rails_tracepoint_stack/truncator"

module RailsTracepointStack
  module Sink
    # Turns live traces into immutable records held in memory, so a caller can
    # inspect them once the traced block is done.
    class Collector
      attr_reader :session, :limits

      def initialize(session: RailsTracepointStack::TraceSession.new, limits: RailsTracepointStack::Limits.new)
        @session = session
        @limits = limits
      end

      def record(trace)
        return if limits.too_deep?(trace.depth)

        unless limits.room_for?(session.traces.size)
          session.truncated = true
          return
        end

        session.add(build_record(trace))
      end

      private

      def build_record(trace)
        exception = trace.exception

        RailsTracepointStack::TraceRecord.new(
          kind: trace.kind,
          class_name: RailsTracepointStack::LogFormatter.stringify(trace.class_name),
          method_name: trace.method_name,
          file_path: trace.file_path,
          line_number: trace.line_number,
          params: params_for(trace),
          return_value: return_value_for(trace),
          exception_class: exception && exception.class.to_s,
          exception_message: exception && RailsTracepointStack::LogFormatter.stringify(exception.message),
          depth: trace.depth || 0
        )
      end

      def params_for(trace)
        return {} unless limits.capture_params

        snapshot(trace.params)
      end

      def return_value_for(trace)
        return nil unless limits.capture_return

        snapshot(trace.return_value)
      end

      def snapshot(value)
        RailsTracepointStack::Truncator.call(
          RailsTracepointStack::LogFormatter.safe_value(value),
          limits
        )
      end
    end
  end
end
