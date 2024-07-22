module RailsTracepointStack
  class Configuration
    attr_accessor :file_path_to_filter_patterns,
      :ignore_patterns,
      :log_format,
      :log_external_sources,
      :logger

    def initialize
      @file_path_to_filter_patterns = []
      @ignore_patterns = []
      @log_format = :text
      @log_external_sources = false
      @logger = nil
    end
  end
end
