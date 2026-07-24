module RailsTracepointStack
  # The traces gathered by one capture, plus whatever the traced block itself
  # produced.
  class TraceSession
    attr_reader :traces
    attr_accessor :result, :error
    attr_writer :truncated

    def initialize
      @traces = []
      @truncated = false
    end

    # True when a limit stopped the collection, so the traces are a prefix of
    # what actually ran rather than the whole story.
    def truncated?
      @truncated
    end

    def add(record)
      @traces << record
    end

    def empty?
      @traces.empty?
    end
  end
end
