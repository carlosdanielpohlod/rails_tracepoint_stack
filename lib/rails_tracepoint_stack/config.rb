module RailsTracepointStack
  class Config
    attr_accessor :ignore_patterns

    def initialize
      @ignore_patterns = []
    end
  end
end
