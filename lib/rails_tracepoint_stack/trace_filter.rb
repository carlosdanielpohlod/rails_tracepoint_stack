require 'rails_tracepoint_stack/filter/gem_path'
require 'rails_tracepoint_stack/filter/rb_config'
require 'rails_tracepoint_stack/filter/custom_trace_selector_filter'
require 'rails_tracepoint_stack/filter/trace_from_dependencies_filter'

module RailsTracepointStack
  class TraceFilter
    include RailsTracepointStack::Filter::CustomTraceSelectorFilter
    include RailsTracepointStack::Filter::TraceFromDependenciesFilter

    def self.ignore_trace?(trace:)
      if not_attends_any_custom_pattern_to_ignore?(trace)
        return true
      end
      if is_a_trace_required_to_watch_by_the_custom_configs?(trace)
        return false
      end
      if should_ignore_because_is_a_internal_dependency?(trace)
        return true
      end
      if should_ignore_because_is_ruby_trace?(trace)
        return true
      end 

      return false
    end

    private
    class << self
      def should_ignore_because_is_ruby_trace?(trace)
        RailsTracepointStack::Filter::TraceFromRubyCodeFilter.ignore_trace?(trace: trace)
      end

      def not_attends_any_custom_pattern_to_ignore?(trace)
        RailsTracepointStack::Filter::TraceToIgnoreFilter.ignore_trace?(trace: trace)
      end
    end
  end
end
