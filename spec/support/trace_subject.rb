# Real classes exercised by the tracer specs. Traces are matched by
# `defined_class`, so these must live outside the spec files that use them.
class TraceSubject
  def self.build(value)
    new
  end

  def add(first, second)
    first + second
  end

  def boom
    raise ArgumentError, "kaboom"
  end

  # Raises from inside a C method rather than from Ruby code, so the raise
  # event reports a stack position deeper than this frame's own.
  def coerce_failure
    1.0 * nil
  end

  def nested(value)
    doubled(value) + 1
  end

  def doubled(value)
    value * 2
  end

  def nested_boom
    boom
  end

  def echo(value)
    value
  end

  def nothing
    nil
  end

  # The locals below are declared but unassigned when the call event fires.
  def with_locals(given)
    doubled = given * 2
    labelled = "n=#{doubled}"
    labelled.upcase
  end

  def with_optionals(first, second = 2, *rest, key: nil, **options)
    [first, second, rest, key, options]
  end

  # Suspends and is never resumed, so this frame never fires a :return.
  def suspended
    Fiber.yield
  end

  def deep(level)
    return level if level <= 0

    deep(level - 1)
  end
end

TraceEntry = Struct.new(:kind, :params, :return_value, :exception, :method_name, :depth)

# Collects whatever the tracer hands it, so specs can assert on real traces
# instead of on a mock's expectations.
class RecordingSink
  attr_reader :records

  def initialize
    @records = []
  end

  def record(trace)
    return unless trace.class_name == TraceSubject

    @records << TraceEntry.new(
      trace.kind, trace.params, trace.return_value, trace.exception, trace.method_name, trace.depth
    )
  end

  def kinds_for(method_name)
    records.select { |record| record.method_name == method_name }.map(&:kind)
  end
end
