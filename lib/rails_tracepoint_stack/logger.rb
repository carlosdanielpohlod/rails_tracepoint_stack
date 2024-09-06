module RailsTracepointStack
  class Logger
    def self.log(msg)
      if RailsTracepointStack.configuration&.logger
        RailsTracepointStack.configuration.logger.info(msg)
      else
        # TODO: Add the support to Rails.env for the default filename
        File.open("log/rails_tracepoint_stack.log", "a") do |f|
          f.puts msg
        end
      end
    end
  end
end
