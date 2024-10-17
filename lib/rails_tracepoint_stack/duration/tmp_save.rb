require 'json'

module RailsTracepointStack
  class TmpSave
    def self.save(trace:, current_time:, last_time:)
      duration = current_time - last_time
      log_obj = {
        time: current_time,
        class: trace.class_name,
        method: trace.method_name,
        file: trace.file_path,
        line: trace.line_number,
        duration: duration
      }
      p log_obj
      File.open("time_log.json", "a") do |file|
        file.puts log_obj.to_json
      end
    end
  end
end
