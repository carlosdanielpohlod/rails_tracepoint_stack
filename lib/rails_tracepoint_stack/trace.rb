require "forwardable"

module RailsTracepointStack
  class Trace
    extend Forwardable

    attr_reader :params, :trace_point
    attr_accessor :depth

    def_delegator :@trace_point, :defined_class, :class_name
    def_delegator :@trace_point, :method_id, :method_name
    def_delegator :@trace_point, :path, :file_path
    def_delegator :@trace_point, :lineno, :line_number

    def initialize(trace_point:)
      @trace_point = trace_point
    end

    def kind
      trace_point.event
    end

    def params
      return {} unless kind == :call

      @params ||= fetch_params(trace_point)
    end

    def return_value
      return nil unless kind == :return

      trace_point.return_value
    end

    def exception
      return nil unless kind == :raise

      trace_point.raised_exception
    end

    private

    def fetch_params(trace_point)
      trace_point.binding.local_variables.map { |var|
        [var, trace_point.binding.local_variable_get(var)]
      }.to_h
    end
  end
end
