require "rails_tracepoint_stack/limits"
require "rails_tracepoint_stack/log_formatter"
require "rails_tracepoint_stack/trace_record"
require "rails_tracepoint_stack/trace_session"
require "rails_tracepoint_stack/truncator"

module RailsTracepointStack
  module Sink
    # Turns live traces into immutable records held in memory, so a caller can
    # inspect them once the traced block is done.
    class Collector
      attr_reader :session, :limits

      def initialize(session: RailsTracepointStack::TraceSession.new, limits: RailsTracepointStack::Limits.new)
        @session = session
        @limits = limits
        @open_block = nil
        @suppressed_returns = Hash.new(0)
      end

      def record(trace)
        return if limits.too_deep?(trace.depth)

        unless limits.room_for?(session.traces.size)
          session.truncated = true
          return
        end

        built = build_record(trace)
        return if collapsed?(built)

        session.add(built)
      end

      private

      # A block written inside a loop runs once per element and reports the
      # same location every time, which buries the trace it belongs to. Runs of
      # the same block at the same depth become one record carrying a count,
      # and the matching returns are dropped with them.
      def collapsed?(record)
        return drop_suppressed_return(record) if record.block_return?
        return break_run(record) unless record.block_call?

        key = [record.file_path, record.line_number, record.depth]

        if @open_block && @open_block.first == key
          @open_block.last.repeats += 1
          @suppressed_returns[record.depth] += 1
          return true
        end

        @open_block = [key, record]
        false
      end

      def drop_suppressed_return(record)
        return false unless @suppressed_returns[record.depth] > 0

        @suppressed_returns[record.depth] -= 1
        true
      end

      # Anything that is not part of the block's own call/return pair ends the
      # run, so two separate loops over the same line stay separate.
      def break_run(record)
        @open_block = nil unless record.returned?
        false
      end

      def build_record(trace)
        exception = trace.exception

        RailsTracepointStack::TraceRecord.new(
          kind: trace.kind,
          class_name: class_name_for(trace),
          method_name: trace.method_name,
          file_path: trace.file_path,
          line_number: trace.line_number,
          params: params_for(trace),
          return_value: return_value_for(trace),
          exception_class: exception && exception.class.to_s,
          exception_message: exception && RailsTracepointStack::LogFormatter.stringify(exception.message),
          depth: trace.depth || 0,
          repeats: 1
        )
      end

      # `to_s` on a class is whatever that class decided to print. ActiveRecord
      # makes a model's singleton class print its entire schema, which turns one
      # method call into hundreds of characters of column definitions. A module
      # knows its own name, so ask for that instead and only fall back to `to_s`
      # for the anonymous ones that have none.
      def class_name_for(trace)
        klass = trace.class_name
        return RailsTracepointStack::LogFormatter.stringify(klass) unless klass.is_a?(Module)

        name = klass.name
        return name if name

        attached = attached_module(klass)
        return "#<Class:#{attached.name}>" if attached&.name

        RailsTracepointStack::LogFormatter.stringify(klass)
      end

      # Singleton classes have no name of their own. Ruby 3.2 can hand back the
      # object they belong to; older versions leave only the printed form.
      def attached_module(klass)
        return nil unless klass.respond_to?(:attached_object)

        attached = klass.attached_object
        attached.is_a?(Module) ? attached : nil
      rescue SystemStackError, StandardError
        nil
      end

      def params_for(trace)
        return {} unless limits.capture_params

        snapshot(trace.params)
      end

      def return_value_for(trace)
        return nil unless limits.capture_return

        snapshot(trace.return_value)
      end

      def snapshot(value)
        RailsTracepointStack::Truncator.bounded(
          RailsTracepointStack::LogFormatter.safe_value(value),
          limits
        )
      end
    end
  end
end
