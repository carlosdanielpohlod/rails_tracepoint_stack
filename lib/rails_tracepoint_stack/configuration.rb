module RailsTracepointStack
  class Configuration
    attr_accessor :ignore_patterns, :logger

    def initialize
      @ignore_patterns = []
      @logger = nil
    end
  end
end
