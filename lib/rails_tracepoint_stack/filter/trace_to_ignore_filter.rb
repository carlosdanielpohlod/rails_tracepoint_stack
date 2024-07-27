module RailsTracepointStack
  module Filter
    class TraceToIgnoreFilter
      def self.ignore_trace?(trace:)
        return false unless RailsTracepointStack.configuration.ignore_patterns.any?
        
        RailsTracepointStack
          .configuration
          .ignore_patterns
          .any? { |pattern| trace.file_path.match?(pattern) }
      end
    end
  end
end
