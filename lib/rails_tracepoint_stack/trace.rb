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

    # Every local the method body declares is already in scope at :call time,
    # holding nil. Reading the whole binding would report those as arguments
    # the caller passed as nil, so the parameter list decides what to read.
    def fetch_params(trace_point)
      binding = trace_point.binding
      declared = binding.local_variables

      trace_point.parameters.each_with_object({}) do |(_type, name), params|
        next if name.nil? || !declared.include?(name)

        params[name] = binding.local_variable_get(name)
      end
    end
  end
end
