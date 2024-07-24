module RailsTracepointStack
  module Filter
    class CustomTraceSelectorFilter
      def self.ignore_trace?(trace:)
        unless filter_match_a_custom_pattern?
          return false
        else
          return true
        end
      end

      private

      def filter_match_a_custom_pattern?
        RailsTracepointStack.configuration.file_path_to_filter_patterns.none? do |pattern|
          trace.file_path.match?(pattern)
        end
      end
    end
  end
end
