module RailsTracepointStack
  class Configuration
    attr_accessor :ignore_patterns, :logger, :log_format

    def initialize
      @ignore_patterns = []
      @logger = nil
      @log_format = :text
    end
  end
end
