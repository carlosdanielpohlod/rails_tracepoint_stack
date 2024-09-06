module RailsTracepointStack
  module Filter
    module TraceToIgnoreFilter
      def attends_some_custom_pattern_to_ignore?(trace:)
        return false unless RailsTracepointStack.configuration.ignore_patterns.any?
        
        RailsTracepointStack
          .configuration
          .ignore_patterns
          .any? { |pattern| trace.file_path.match?(pattern) }
      end
    end
  end
end
