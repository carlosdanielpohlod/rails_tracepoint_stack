require 'rails_tracepoint_stack/filter/gem_path'
require 'rails_tracepoint_stack/filter/rb_config'

module RailsTracepointStack
  class TraceFilter
    def self.ignore_trace?(trace:)
      if defined_custom_patterns_to_watch? && not_attends_the_custom_pattern_to_watch?(trace)
        return true
      end
      if should_ignore_because_is_a_internal_dependency?(trace)
        return true
      end 
      if should_ignore_because_is_ruby_trace?(trace)
        return true
      end 
      if should_ignore_because_not_is_a_trace_required_by_the_custom_configs?(trace)
        return true
      end
      return false
    end

    private

    def should_ignore_because_is_ruby_trace?(trace)
      ::Filter::TraceFromRubyCodeFilter.ignore_trace?(trace: trace)
    end

    def not_is_a_trace_required_by_the_custom_configs?(trace)
      ::Filter::CustomTraceSelectorFilter.ignore_trace?(trace: trace)
    end

    def should_ignore_because_is_a_internal_dependency?(trace)
      ::Filter::TraceFromDependenciesFilter.ignore_trace?(trace: trace)
    end

    def not_attends_the_custom_pattern_to_watch?(trace)
      ::Filter::TraceToIgnoreFilter.ignore_trace?(trace: trace)
    end

    def defined_custom_patterns_to_watch?
      RailsTracepointStack.configuration.file_path_to_filter_patterns.any?
    end   
  end
end
