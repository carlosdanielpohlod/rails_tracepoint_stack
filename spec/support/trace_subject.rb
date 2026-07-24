# Real classes exercised by the tracer specs. Traces are matched by
# `defined_class`, so these must live outside the spec files that use them.
class TraceSubject
  def add(first, second)
    first + second
  end

  def boom
    raise ArgumentError, "kaboom"
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
end

TraceEntry = Struct.new(:kind, :params, :return_value, :exception, :method_name)

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
      trace.kind, trace.params, trace.return_value, trace.exception, trace.method_name
    )
  end

  def kinds_for(method_name)
    records.select { |record| record.method_name == method_name }.map(&:kind)
  end
end
