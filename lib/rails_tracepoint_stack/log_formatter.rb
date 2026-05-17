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
      "called: #{trace.class_name}##{trace.method_name} in #{trace.file_path}:#{trace.line_number} with params: #{text_value(trace.params)}"
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
        safe_json_object(value)
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
        result[safe_hash_key(key, ancestry)] = safe_value(item, ancestry)
      end
    ensure
      ancestry.delete(object_id)
    end

    def self.safe_hash_key(key, ancestry = {})
      case key
      when String
        key
      when Symbol, Numeric
        key.to_s
      when true, false, nil
        key.inspect
      else
        stringify_hash_key(key, ancestry)
      end
    end

    def self.safe_json_object(value)
      json_value = JSON.parse(JSON.generate(value))

      return json_value unless default_string_representation?(value, json_value)

      safe_object_string(value)
    rescue SystemStackError, StandardError
      safe_object_string(value)
    end

    def self.default_string_representation?(value, json_value)
      json_value.is_a?(String) &&
        value.method(:to_s).owner == Kernel &&
        json_value == value.to_s
    rescue SystemStackError, StandardError
      false
    end

    def self.stringify_hash_key(key, ancestry)
      normalized_key = safe_value(key, ancestry)

      case normalized_key
      when String
        normalized_key
      when nil
        "null"
      when true, false, Numeric
        normalized_key.to_s
      else
        JSON.generate(normalized_key)
      end
    rescue SystemStackError, StandardError
      safe_object_string(key)
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

    def self.text_value(value, ancestry = {})
      case value
      when nil
        "nil"
      when true, false, Numeric
        value.to_s
      when String
        value.inspect
      when Symbol
        ":#{value}"
      when Array
        text_array(value, ancestry)
      when Hash
        text_hash(value, ancestry)
      else
        safe_object_string(value)
      end
    rescue SystemStackError, StandardError => error
      inspect_fallback(value, error)
    end

    def self.text_array(value, ancestry)
      object_id = value.__id__
      return recursive_placeholder(value) if ancestry.key?(object_id)

      ancestry[object_id] = true
      "[#{value.map { |item| text_value(item, ancestry) }.join(", ")}]"
    ensure
      ancestry.delete(object_id)
    end

    def self.text_hash(value, ancestry)
      object_id = value.__id__
      return recursive_placeholder(value) if ancestry.key?(object_id)

      ancestry[object_id] = true
      pairs = value.map do |key, item|
        "#{text_hash_key(key, ancestry)}=>#{text_value(item, ancestry)}"
      end

      "{#{pairs.join(", ")}}"
    ensure
      ancestry.delete(object_id)
    end

    def self.text_hash_key(key, ancestry = {})
      case key
      when Symbol
        ":#{key}"
      when String
        key.inspect
      else
        text_value(key, ancestry)
      end
    end
  end
end
