# frozen_string_literal: true

module RailsTracepointStack
  module LogFormatter
    def self.message(trace)
      case RailsTracepointStack.configuration&.log_format
      when :json
        json trace
      else
        text trace
      end
    end

    def self.text(trace)
      "called: #{trace.class_name}##{trace.method_name} in #{trace.file_path}:#{trace.line_number} with params: #{trace.params}"
    end

    def self.json(trace)
      {
        class: trace.class_name,
        method_name: trace.method_name,
        path: trace.file_path,
        line: trace.line_number,
        params: trace.params
      }.to_json
    end
  end
end
