module RailsTracepointStack
  class Logger
    def self.log(msg)
      if RailsTracepointStack.configuration&.logger
        RailsTracepointStack.configuration.logger.info(msg)
      else
        File.open("log/rails_tracepoint_stack_#{Rails.env}.log", 'a') do |f|
          f.puts msg
        end
      end
    end
  end
end
