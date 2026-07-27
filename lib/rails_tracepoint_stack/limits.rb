module RailsTracepointStack
  # How much a capture is allowed to keep. The defaults aim at an output a
  # person or an agent can read in one go rather than at completeness: a
  # single Rails request can easily produce tens of thousands of traces.
  class Limits
    DEFAULT_MAX_TRACES = 5_000
    DEFAULT_MAX_STRING_LENGTH = 200
    DEFAULT_MAX_COLLECTION_SIZE = 20
    DEFAULT_MAX_VALUE_LENGTH = 1_000

    attr_reader :max_depth,
      :max_traces,
      :max_string_length,
      :max_collection_size,
      :max_value_length,
      :capture_params,
      :capture_return

    def initialize(
      max_depth: nil,
      max_traces: DEFAULT_MAX_TRACES,
      max_string_length: DEFAULT_MAX_STRING_LENGTH,
      max_collection_size: DEFAULT_MAX_COLLECTION_SIZE,
      max_value_length: DEFAULT_MAX_VALUE_LENGTH,
      capture_params: true,
      capture_return: true
    )
      @max_depth = max_depth
      @max_traces = max_traces
      @max_string_length = max_string_length
      @max_collection_size = max_collection_size
      @max_value_length = max_value_length
      @capture_params = capture_params
      @capture_return = capture_return
    end

    def too_deep?(depth)
      !max_depth.nil? && !depth.nil? && depth > max_depth
    end

    def room_for?(count)
      max_traces.nil? || count < max_traces
    end
  end
end
