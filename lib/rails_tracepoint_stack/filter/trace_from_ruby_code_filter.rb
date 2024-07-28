module RailsTracepointStack
  module Filter
    module TraceFromRubyCodeFilter
      def should_ignore_because_is_ruby_trace?(trace:)
        return false if not_ignore_external_source_traces?

        trace.file_path.start_with?('<internal:') || trace.file_path == '(eval)'
      end 

      private

      def not_ignore_external_source_traces?
        RailsTracepointStack.configuration.log_external_sources
      end
    end
  end
end
