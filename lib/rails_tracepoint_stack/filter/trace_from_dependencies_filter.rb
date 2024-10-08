require 'rails_tracepoint_stack/filter/gem_path'
require 'rails_tracepoint_stack/filter/rb_config'

module RailsTracepointStack
  module Filter
    module TraceFromDependenciesFilter
      def should_ignore_because_is_a_internal_dependency?(trace:)
        return false if not_ignore_external_source_traces?
        
        file_path_starts_with_gem_path?(trace) ||
        file_path_starts_with_ruby_lib_path?(trace) ||
        file_path_include_bundler_gems_path?(trace)
      end

      private

      def file_path_starts_with_gem_path?(trace)
        gem_paths.any? { |path| trace.file_path.start_with?(path) }
      end
   
      def file_path_starts_with_ruby_lib_path?(trace)
        trace.file_path.start_with?(ruby_lib_path)
      end
  
      def file_path_include_bundler_gems_path?(trace)
        trace.file_path.include?("gems/bundler")
      end
  
      def gem_paths
        @gem_paths ||= RailsTracepointStack::Filter::GemPath.full_gem_path
      end
  
      def ruby_lib_path
        @ruby_lib_path ||= RailsTracepointStack::Filter::RbConfig.ruby_lib_path
      end

      def not_ignore_external_source_traces?
        RailsTracepointStack.configuration.log_external_sources
      end
    end
  end
end
