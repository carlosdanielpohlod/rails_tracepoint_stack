module RailsTracepointStack
  module Duration
    class Output
      attr :file_durations
      
      def initialize
        @file_durations = Hash.new(0)
        compute_duration!
      end

      def show_top_files
        top_10_files.each_with_index do |(file, total_duration), index|
          puts "#{index + 1}. File: #{file} - Total Duration: #{total_duration.round(6)} seconds"
        end
      end

      private

      def compute_duration!
        File.open("time_log.json", "r").each_line do |line|
          data = JSON.parse(line)
        
          file = data["file"]
          duration = data["duration"]
        
          file_durations[file] += duration
        end
      end
      #TODO: turn the number of files flexible
      def top_10_files
        @top_10_files ||= file_durations.sort_by { |_, total_duration| -total_duration }.first(10)
      end
    end
  end
end
