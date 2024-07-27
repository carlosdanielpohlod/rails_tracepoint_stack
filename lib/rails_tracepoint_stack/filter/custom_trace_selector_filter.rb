module RailsTracepointStack
  module Filter
    class CustomTraceSelectorFilter
      def self.ignore_trace?(trace:)
        !filter_match_a_custom_pattern?(trace)
      end

      private

      def self.filter_match_a_custom_pattern?(trace)
        RailsTracepointStack.configuration.file_path_to_filter_patterns.any? do |pattern|
          trace.file_path.match?(pattern)
        end
      end
    end
  end
end
