module RailsTracepointStack
  class Logger
    def self.log(msg)
      if RailsTracepointStack.configuration.logger.nil?
        File.open('log/rails_tracepoint_stack.log', 'a') do |f|
          f.puts msg
        end
      else
        RailsTracepointStack.configuration.logger.info(msg)
      end
    end
  end
end

