require "json"

module RailsTracepointStack
  module Renderer
    # Renders a session as an indented call tree.
    #
    # The format is built for reading in a terminal or pasting into a prompt,
    # so it favours short lines: paths are relative to the working directory,
    # values are compact JSON, and a return sits one level under the call it
    # belongs to.
    module Tree
      INDENT = "  ".freeze

      def self.call(session)
        lines = session.traces.map { |record| line_for(record) }
        lines << truncation_notice if session.truncated?
        lines << Summary.line(session)
        lines.join("\n")
      end

      def self.line_for(record)
        case record.kind
        when :call then call_line(record)
        when :return then return_line(record)
        when :raise then raise_line(record)
        end
      end

      def self.call_line(record)
        "#{indent(record.depth)}#{record.class_name}##{record.method_name} " \
          "(#{location(record)}) #{compact(record.params)}"
      end

      def self.return_line(record)
        "#{indent(record.depth + 1)}-> #{compact(record.return_value)}"
      end

      def self.raise_line(record)
        "#{indent(record.depth + 1)}!! #{record.exception_class}: #{record.exception_message}"
      end

      def self.truncation_notice
        "... truncated: the limit was reached before the block finished"
      end

      def self.indent(depth)
        INDENT * depth
      end

      def self.location(record)
        "#{relative_path(record.file_path)}:#{record.line_number}"
      end

      def self.relative_path(file_path)
        return file_path unless file_path.to_s.start_with?("#{Dir.pwd}/")

        file_path[(Dir.pwd.length + 1)..]
      end

      def self.compact(value)
        JSON.generate(value)
      rescue SystemStackError, StandardError
        value.to_s
      end
    end
  end
end
