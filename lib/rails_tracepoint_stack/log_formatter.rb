require "json"

module RailsTracepointStack
  module LogFormatter
    def self.message(trace)
      case RailsTracepointStack.configuration&.log_format
      when :json
        json trace
      else
        text trace
      end
    end

    def self.text(trace)
      "called: #{trace.class_name}##{trace.method_name} in #{trace.file_path}:#{trace.line_number} with params: #{trace.params}"
    end

    def self.json(trace)
      JSON.generate(
        class: stringify(trace.class_name),
        method_name: stringify(trace.method_name),
        path: stringify(trace.file_path),
        line: trace.line_number,
        params: safe_value(trace.params)
      )
    end

    def self.stringify(value)
      return nil if value.nil?

      value.to_s
    rescue SystemStackError, StandardError => error
      inspect_fallback(value, error)
    end

    def self.safe_value(value, ancestry = {})
      case value
      when nil, true, false, Numeric, String
        value
      when Symbol
        value.to_s
      when Array
        safe_array(value, ancestry)
      when Hash
        safe_hash(value, ancestry)
      else
        safe_object_string(value)
      end
    rescue SystemStackError, StandardError => error
      inspect_fallback(value, error)
    end

    def self.safe_array(value, ancestry)
      object_id = value.__id__
      return recursive_placeholder(value) if ancestry.key?(object_id)

      ancestry[object_id] = true
      value.map { |item| safe_value(item, ancestry) }
    ensure
      ancestry.delete(object_id)
    end

    def self.safe_hash(value, ancestry)
      object_id = value.__id__
      return recursive_placeholder(value) if ancestry.key?(object_id)

      ancestry[object_id] = true
      value.each_with_object({}) do |(key, item), result|
        result[safe_hash_key(key)] = safe_value(item, ancestry)
      end
    ensure
      ancestry.delete(object_id)
    end

    def self.safe_hash_key(key)
      case key
      when String
        key
      when Symbol, Numeric
        key.to_s
      when true, false, nil
        key.inspect
      else
        safe_object_string(key)
      end
    end

    def self.safe_object_string(value)
      value.inspect
    rescue SystemStackError, StandardError => error
      inspect_fallback(value, error)
    end

    def self.inspect_fallback(value, error)
      class_name = value.nil? ? "NilClass" : value.class.to_s
      "#<#{class_name} unserializable: #{error.class}: #{error.message}>"
    end

    def self.recursive_placeholder(value)
      "[recursive #{value.class}]"
    end
  end
end
