module RailsTracepointStack
  module Filter
    module CustomTraceSelectorFilter
      def is_a_trace_required_to_watch_by_the_custom_configs?(trace:)
        return false unless RailsTracepointStack.configuration.file_path_to_filter_patterns.any?

        filter_match_a_custom_pattern_to_be_not_ignored?(trace)
      end

      private

      def filter_match_a_custom_pattern_to_be_not_ignored?(trace)
        RailsTracepointStack.configuration.file_path_to_filter_patterns.any? do |pattern|
          trace.file_path.match?(pattern)
        end
      end
    end
  end
end
