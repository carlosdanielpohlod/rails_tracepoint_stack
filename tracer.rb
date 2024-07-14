gem_paths = Bundler.load.specs.map(&:full_gem_path)
ruby_lib_path = RbConfig::CONFIG['rubylibdir']

trace = TracePoint.new(:call) do |tp|
  next if tp.path.start_with?('<internal:') || tp.path == '(eval)' || gem_paths.any? { |path| tp.path.start_with?(path) } || tp.path.start_with?(ruby_lib_path)

  params = tp.binding.local_variables.map { |var|
    [var, tp.binding.local_variable_get(var)]
  }.to_h

  puts "called: #{tp.defined_class}##{tp.method_id} in #{tp.path}:#{tp.lineno} with params: #{params}"
end

trace.enable

at_exit do
  trace.disable
end
