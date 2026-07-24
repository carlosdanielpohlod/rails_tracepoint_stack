module RailsTracepointStack
  # An immutable snapshot of a single trace. The TracePoint object is only
  # valid while its event is being handled, so anything worth keeping has to
  # be copied out before the handler returns.
  TraceRecord = Struct.new(
    :kind,
    :class_name,
    :method_name,
    :file_path,
    :line_number,
    :params,
    :return_value,
    :exception_class,
    :exception_message,
    keyword_init: true
  ) do
    def call?
      kind == :call
    end

    def return?
      kind == :return
    end

    def raise?
      kind == :raise
    end
  end
end
