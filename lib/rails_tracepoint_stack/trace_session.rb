module RailsTracepointStack
  # The traces gathered by one capture, plus whatever the traced block itself
  # produced.
  class TraceSession
    attr_reader :traces
    attr_accessor :result, :error

    def initialize
      @traces = []
    end

    def add(record)
      @traces << record
    end

    def empty?
      @traces.empty?
    end
  end
end
