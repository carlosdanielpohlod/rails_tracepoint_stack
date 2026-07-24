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
        lines << empty_notice(session) if session.traces.empty?
        lines.join("\n")
      end

      # An empty tree reads like a broken tool. It usually means the block ran
      # entirely inside gems - a bare ActiveRecord query calls no method the
      # developer wrote - so say which of the two happened.
      def self.empty_notice(session)
        return "no code ran inside the block" if session.filtered_count.to_i.zero?

        "no app code ran: #{session.filtered_count} traces from gems, the framework " \
          "and Ruby itself were filtered out"
      end

      def self.line_for(record)
        case record.kind
        when :call then call_line(record)
        when :return then return_line(record)
        when :raise then raise_line(record)
        end
      end

      SINGLETON_CLASS = /\A#<Class:([A-Z][\w:]*)>\z/
      TEMPLATE_FILE = /\.(erb|haml|slim|builder|jbuilder|rabl)\z/i
      # Everything a template receives besides the locals belongs to the
      # rendering machinery, not to the developer.
      TEMPLATE_LOCALS = "local_assigns".freeze

      def self.call_line(record)
        return template_line(record) if template?(record)

        "#{indent(record.depth)}#{qualified_name(record)} " \
          "(#{location(record)}) #{compact(record.params)}"
      end

      # A class method is defined on the singleton class, which prints as
      # #<Class:Foo>. Ruby writes that call as Foo.bar, so the tree does too.
      # An anonymous singleton prints as an address and is left alone, since
      # turning that into `0x00007f1234.render` helps nobody.
      def self.qualified_name(record)
        singleton = SINGLETON_CLASS.match(record.class_name.to_s)
        return "#{singleton[1]}.#{record.method_name}" if singleton

        "#{record.class_name}##{record.method_name}"
      end

      # A compiled template is a generated method on an anonymous class, named
      # after a hash of the file. None of that is worth showing: the path is.
      def self.template?(record)
        TEMPLATE_FILE.match?(record.file_path.to_s)
      end

      def self.template_line(record)
        "#{indent(record.depth)}render #{relative_path(record.file_path)} " \
          "#{compact(template_locals(record))}"
      end

      def self.template_locals(record)
        params = record.params
        return {} unless params.is_a?(Hash)

        params.fetch(TEMPLATE_LOCALS, {})
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
