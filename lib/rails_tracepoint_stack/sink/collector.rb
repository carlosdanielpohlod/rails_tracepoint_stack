require "rails_tracepoint_stack/log_formatter"
require "rails_tracepoint_stack/trace_record"
require "rails_tracepoint_stack/trace_session"

module RailsTracepointStack
  module Sink
    # Turns live traces into immutable records held in memory, so a caller can
    # inspect them once the traced block is done.
    class Collector
      attr_reader :session

      def initialize(session: RailsTracepointStack::TraceSession.new)
        @session = session
      end

      def record(trace)
        @session.add(build_record(trace))
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
          params: RailsTracepointStack::LogFormatter.safe_value(trace.params),
          return_value: RailsTracepointStack::LogFormatter.safe_value(trace.return_value),
          exception_class: exception && exception.class.to_s,
          exception_message: exception && RailsTracepointStack::LogFormatter.stringify(exception.message),
          depth: trace.depth || 0
        )
      end
    end
  end
end
