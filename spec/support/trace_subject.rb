# Real classes exercised by the tracer specs. Traces are matched by
# `defined_class`, so these must live outside the spec files that use them.
class TraceSubject
  # A Rails scope is a lambda held at class-body level: TracePoint reports it
  # with no defining class and no method name.
  SCOPE_LIKE = lambda { |factor| factor * 3 }

  def self.build(value)
    new
  end

  # The block runs once per element, all from the same line — the shape that
  # floods a trace.
  def repeated_block
    [1, 2, 3, 4, 5].map { |number| number * 2 }
  end

  def runs_scope_like(factor)
    SCOPE_LIKE.call(factor)
  end

  def yields_once
    yield 7
  end

  def calls_a_block
    yields_once { |value| value + 1 }
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

# ActiveRecord makes a model's singleton class print its whole schema, and
# leaves its `name` nil. This reproduces that shape without pulling in Rails.
class NoisySingletonSubject
  def self.build(value)
    value * 2
  end

  def self.many_objects
    Array.new(80) { |index| Struct.new(:a, :b, :c).new("x" * 120, index, "y" * 120) }
  end
end

NoisySingletonSubject.singleton_class.define_singleton_method(:to_s) do
  "#<Class:NoisySingletonSubject (call 'NoisySingletonSubject.load_schema' " \
    "to load schema information)>"
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
