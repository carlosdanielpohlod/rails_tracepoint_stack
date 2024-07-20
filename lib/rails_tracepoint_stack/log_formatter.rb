module RailsTracepointStack
  module LogFormatter
    def self.message(tp, params)
      case RailsTracepointStack.configuration&.log_format
      when :json
        json tp, params
      else
        text tp, params
      end
    end

    def self.text(tp, params)
      "called: #{tp.defined_class}##{tp.method_id} in #{tp.path}:#{tp.lineno} with params: #{params}"
    end

    def self.json(tp, params)
      {
        class: tp.defined_class,
        method_id: tp.method_id,
        path: tp.path,
        line: tp.lineno,
        params: params
        }.to_json
    end
  end
end
