# frozen_string_literal: true

require 'forwardable'

module RailsTracepointStack
  class Trace
    extend Forwardable

    attr_reader :params, :trace_point

    def_delegator :@trace_point, :defined_class, :class_name
    def_delegator :@trace_point, :method_id, :method_name
    def_delegator :@trace_point, :path, :file_path
    def_delegator :@trace_point, :lineno, :line_number

    def initialize(trace_point:)
      @trace_point = trace_point
    end

    def params
      @params ||= fetch_params(trace_point)
    end

    private

    def fetch_params(trace_point)
      trace_point.binding.local_variables.map do |var|
        [var, trace_point.binding.local_variable_get(var)]
      end.to_h
    end
  end
end
