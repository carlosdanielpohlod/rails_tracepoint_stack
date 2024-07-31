require 'rails_tracepoint_stack/filter/custom_trace_selector_filter'
require 'rails_tracepoint_stack/filter/trace_from_dependencies_filter'
require 'rails_tracepoint_stack/filter/trace_from_ruby_code_filter'
require 'rails_tracepoint_stack/filter/trace_to_ignore_filter'

module RailsTracepointStack
  module TraceFilter
    include RailsTracepointStack::Filter::CustomTraceSelectorFilter
    include RailsTracepointStack::Filter::TraceFromDependenciesFilter
    include RailsTracepointStack::Filter::TraceFromRubyCodeFilter
    include RailsTracepointStack::Filter::TraceToIgnoreFilter

    def ignore_trace?(trace:)
      if attends_some_custom_pattern_to_ignore?(trace: trace)
        return true
      end
      if is_a_trace_required_to_watch_by_the_custom_configs?(trace: trace)
        return false
      end
      if should_ignore_because_is_a_internal_dependency?(trace: trace)
        return true
      end
      if should_ignore_because_is_ruby_trace?(trace: trace)
        return true
      end 

      return false
    end
  end
end
