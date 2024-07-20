module RailsTracepointStack
  class Output
    def self.log(trace:)
      RailsTracepointStack::Logger.log "called: #{trace.class_name}##{trace.method_name} in #{trace.file_path}:#{trace.line_number} with params: #{trace.params}"
    end
  end
end
