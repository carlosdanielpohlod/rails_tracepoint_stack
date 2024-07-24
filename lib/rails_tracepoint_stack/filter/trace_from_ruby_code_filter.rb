module RailsTracepointStack
  module Filter
    class TraceFromRubyCodeFilter
      def self.ignore_trace?(trace:)
        return false if not_ignore_external_source_traces?

        trace.file_path.start_with?('<internal:') || trace.file_path == '(eval)'
      end 

      private

      def not_ignore_external_source_traces?
        return false if RailsTracepointStack.configuration.log_external_sources
      end
    end
  end
end
