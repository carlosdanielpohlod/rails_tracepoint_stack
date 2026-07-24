module RailsTracepointStack
  # Shrinks an already-serialized value so one fat argument (a big payload, a
  # long SQL string, a loaded association) cannot dominate the output. Runs
  # over the plain structures LogFormatter.safe_value produces, so it only
  # ever sees strings, numbers, booleans, nil, arrays and hashes.
  module Truncator
    ELLIPSIS = "…".freeze

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
