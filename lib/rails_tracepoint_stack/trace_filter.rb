module RailsTracepointStack
  class TraceFilter
    def self.ignore_trace?(trace:)
      start_with_to_ignore_prefixes?(trace) || from_gempath_or_lib_path?(trace) || is_a_to_ignore_pattern?(trace)
    end

    private

    def self.gem_paths
      @gem_paths ||= Bundler.load.specs.map(&:full_gem_path)
    end

    def self.ruby_lib_path
      @ruby_lib_path ||= RbConfig::CONFIG['rubylibdir']
    end
    
    def self.start_with_to_ignore_prefixes?(trace)
      trace.path.start_with?('<internal:') || trace.path == '(eval)'
    end

    def self.from_gempath_or_lib_path?(trace)
      gem_paths.any? { |path| trace.path.start_with?(path) } || 
        trace.path.start_with?(ruby_lib_path) || 
          trace.path.include?("gems/bundler")
    end

    def self.is_a_to_ignore_pattern?(trace)
      RailsTracepointStack.configuration&.ignore_patterns&.any? { |pattern| trace.path.match?(pattern) }
    end
  end
end
