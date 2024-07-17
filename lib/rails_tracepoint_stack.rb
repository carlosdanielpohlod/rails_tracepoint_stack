module RailsTracepointStack
  autoload :VERSION, "rails_tracepoint_stack/version"
  @@rails_tracer_rtps = nil

  class RailsTracepointStack
    def initialize
      @gem_paths = Bundler.load.specs.map(&:full_gem_path)
      @ruby_lib_path = RbConfig::CONFIG['rubylibdir']
    end
  
    def tracer
      @trace ||=  TracePoint.new(:call) do |tp|
        next if start_with_to_ignore_prefixes?(tp) || from_gempath_or_lib_path?(tp)
  
        params = fetch_params(tp)
        
        puts "called: #{tp.defined_class}##{tp.method_id} in #{tp.path}:#{tp.lineno} with params: #{params}"
      end
    end
  
    private
    attr_reader :gem_paths, :ruby_lib_path
  
    def fetch_params(tp)
      tp.binding.local_variables.map { |var|
        [var, tp.binding.local_variable_get(var)]
      }.to_h
    end
  
    def start_with_to_ignore_prefixes?(tp)
      tp.path.start_with?('<internal:') || tp.path == '(eval)'
    end
  
    def from_gempath_or_lib_path?(tp)
      gem_paths.any? { |path| tp.path.start_with?(path) } || 
      tp.path.start_with?(ruby_lib_path) || 
      tp.path.include?("gems/bundler") 
    end
  end

  if ENV.fetch('ENABLE_RAILS_TRACEPOINT_STACK', 'false') == 'true'
    @@rails_tracer_rtps = RailsTracepointStack.new
    @@rails_tracer_rtps.tracer.enable
  
    at_exit do
      @@rails_tracer_rtps.tracer.disable
    end
  end
end
