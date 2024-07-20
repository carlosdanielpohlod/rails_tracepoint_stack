require 'rails_tracepoint_stack/filter/gem_path'
require 'rails_tracepoint_stack/filter/rb_config'

module RailsTracepointStack
  class TraceFilter
    def self.ignore_trace?(trace:)
      if defined_file_path_to_filter_patterns?
        not_matches_file_path_to_filter_patterns?(trace)
      else
        contains_to_ignore_strings?(trace) || from_gempath_or_lib_path?(trace) || is_a_to_ignore_pattern?(trace)
      end
    end

    private

    def self.contains_to_ignore_strings?(trace)
      trace.file_path.start_with?('<internal:') || trace.file_path == '(eval)'
    end

    def self.from_gempath_or_lib_path?(trace)
      file_path_starts_with_gem_path?(trace) || 
      file_path_starts_with_ruby_lib_path?(trace) || 
      file_path_starts_with_bundler_path?(trace)
    end

    def self.is_a_to_ignore_pattern?(trace)
      RailsTracepointStack.configuration&.ignore_patterns&.any? { |pattern| trace.file_path.match?(pattern) }
    end

    def self.file_path_starts_with_gem_path?(trace)
     gem_paths.any? { |path| trace.file_path.start_with?(path) }
    end

    def self.file_path_starts_with_ruby_lib_path?(trace)
      trace.file_path.start_with?(ruby_lib_path)
    end

    def self.file_path_starts_with_bundler_path?(trace)
      trace.file_path.include?("gems/bundler")
    end

    def self.gem_paths
      @gem_paths ||= RailsTracepointStack::Filter::GemPath.full_gem_path
    end

    def self.ruby_lib_path
      @ruby_lib_path ||= RailsTracepointStack::Filter::RbConfig.ruby_lib_path
    end

    def self.defined_file_path_to_filter_patterns?
      RailsTracepointStack.configuration&.file_path_to_filter_patterns&.any?
    end

    def self.not_matches_file_path_to_filter_patterns?(trace)
      !RailsTracepointStack.configuration.file_path_to_filter_patterns.any? do |pattern|
        trace.file_path.match?(pattern)
      end
    end
  end
end
