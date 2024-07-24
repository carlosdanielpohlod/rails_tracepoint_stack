module RailsTracepointStack
  module Filter
    class TraceToIgnoreFilter
      def self.ignore_trace?(trace:)
        RailsTracepointStack
          .configuration
          .ignore_patterns
          .any? { |pattern| trace.file_path.match?(pattern) }
      end
    end
  end
end
