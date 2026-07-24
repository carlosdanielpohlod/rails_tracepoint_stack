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
