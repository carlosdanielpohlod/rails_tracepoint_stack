module RailsTracepointStack
  module Renderer
    # Counts what a session holds, so a reader can tell at a glance whether
    # the capture saw what they expected before reading the tree itself.
    module Summary
      def self.call(session)
        {
          calls: count(session, :call),
          returns: count(session, :return),
          raises: count(session, :raise),
          classes: session.traces.map(&:class_name).uniq.size,
          filtered: session.filtered_count,
          truncated: session.truncated?
        }
      end

      def self.line(session)
        counts = call(session)

        [
          pluralize(counts[:calls], "call"),
          pluralize(counts[:returns], "return"),
          pluralize(counts[:raises], "raise"),
          pluralize(counts[:classes], "class", "classes")
        ].join(", ")
      end

      def self.count(session, kind)
        session.traces.count { |record| record.kind == kind }
      end

      def self.pluralize(count, singular, plural = "#{singular}s")
        "#{count} #{(count == 1) ? singular : plural}"
      end
    end
  end
end
