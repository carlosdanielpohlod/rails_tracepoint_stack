require "json"
require "rails_tracepoint_stack/renderer/summary"
require "rails_tracepoint_stack/renderer/tree"

module RailsTracepointStack
  # The traces gathered by one capture, plus whatever the traced block itself
  # produced.
  class TraceSession
    attr_reader :traces
    attr_accessor :result, :error, :filtered_count
    attr_writer :truncated

    def initialize
      @traces = []
      @truncated = false
      @filtered_count = 0
    end

    def add(record)
      @traces << record
    end

    def empty?
      @traces.empty?
    end

    # True when a limit stopped the collection, so the traces are a prefix of
    # what actually ran rather than the whole story.
    def truncated?
      @truncated
    end

    def to_tree
      RailsTracepointStack::Renderer::Tree.call(self)
    end
    alias_method :to_s, :to_tree

    def summary
      RailsTracepointStack::Renderer::Summary.call(self)
    end

    def as_json
      {
        summary: summary,
        traces: traces.map { |record| entry_for(record) }
      }
    end

    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    private

    def entry_for(record)
      entry = {
        kind: record.kind,
        depth: record.depth,
        class_name: record.class_name,
        method_name: record.method_name,
        file_path: "#{RailsTracepointStack::Renderer::Tree.relative_path(record.file_path)}:#{record.line_number}",
        params: record.params
      }

      # A method that returned nil is often the answer being looked for, so
      # the key stays even when there is nothing in it.
      entry[:return_value] = record.return_value if record.return?

      if record.raise?
        entry[:exception_class] = record.exception_class
        entry[:exception_message] = record.exception_message
      end

      entry
    end
  end
end
