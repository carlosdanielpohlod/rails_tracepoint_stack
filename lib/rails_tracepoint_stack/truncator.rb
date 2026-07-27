require "json"

module RailsTracepointStack
  # Shrinks an already-serialized value so one fat argument (a big payload, a
  # long SQL string, a loaded association) cannot dominate the output. Runs
  # over the plain structures LogFormatter.safe_value produces, so it only
  # ever sees strings, numbers, booleans, nil, arrays and hashes.
  module Truncator
    ELLIPSIS = "…".freeze

    # Per-string and per-collection limits still leave room for one value to
    # run to thousands of characters: twenty items each truncated to two
    # hundred is still four thousand. This caps the value as a whole, and does
    # it before the per-item truncation so the summary can report the real
    # size rather than the already-shrunk one.
    def self.bounded(value, limits)
      capped = cap(value, limits)
      return capped unless capped.equal?(value)

      call(value, limits)
    end

    def self.cap(value, limits)
      max = limits.max_value_length
      return value if max.nil?
      return value unless value.is_a?(String) || value.is_a?(Array) || value.is_a?(Hash)

      size = JSON.generate(value).length
      return value if size <= max

      summarize(value, size)
    rescue SystemStackError, StandardError
      value
    end

    def self.summarize(value, size)
      case value
      when Array then "[#{value.size} items, #{size} chars — over max_value_length]"
      when Hash then "{#{value.size} keys, #{size} chars — over max_value_length}"
      else "[#{size} chars — over max_value_length]"
      end
    end

    def self.call(value, limits)
      case value
      when String then truncate_string(value, limits)
      when Array then truncate_array(value, limits)
      when Hash then truncate_hash(value, limits)
      else value
      end
    end

    def self.truncate_string(value, limits)
      max = limits.max_string_length
      return value if max.nil? || value.length <= max

      "#{value[0, max]}#{ELLIPSIS} (#{value.length} chars)"
    end

    def self.truncate_array(value, limits)
      max = limits.max_collection_size
      kept = (max.nil? || value.length <= max) ? value : value.first(max)
      result = kept.map { |item| call(item, limits) }

      return result if kept.length == value.length

      result << "(+#{value.length - kept.length} more)"
    end

    def self.truncate_hash(value, limits)
      max = limits.max_collection_size
      dropped = (max.nil? || value.size <= max) ? 0 : value.size - max
      kept = dropped.zero? ? value : value.first(max).to_h

      result = kept.each_with_object({}) do |(key, item), memo|
        memo[key] = call(item, limits)
      end

      return result if dropped.zero?

      result[ELLIPSIS] = "(+#{dropped} more)"
      result
    end
  end
end
