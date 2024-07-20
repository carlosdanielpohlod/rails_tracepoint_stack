module RailsTracepointStack
  class Configuration
    attr_accessor :ignore_patterns, :logger, :log_format, :file_path_to_filter_patterns

    def initialize
      @ignore_patterns = []
      @file_path_to_filter_patterns = []
      @logger = nil
      @log_format = :text
    end
  end
end
