require "spec_helper"

RSpec.describe "session rendering" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  let(:session) { RailsTracepointStack.capture { TraceSubject.new.nested(3) } }
  let(:lines) { session.to_tree.lines.map(&:chomp) }

  describe "#to_tree" do
    it "renders the outermost call unindented, with location and params" do
      expect(lines.first)
        .to match(%r{\ATraceSubject#nested \(spec/support/trace_subject\.rb:\d+\) \{"value":3\}\z})
    end

    it "indents a nested call by one level" do
      expect(lines).to include(a_string_matching(/\A {2}TraceSubject#doubled \(/))
    end

    it "renders a return value below its own call" do
      expect(lines).to include("    -> 6")
    end

    it "renders the outer return at the outer level" do
      expect(lines).to include("  -> 7")
    end

    it "makes paths relative to the working directory" do
      expect(session.to_tree).not_to include(Dir.pwd)
    end

    it "renders a raise with its class and message" do
      failed = RailsTracepointStack.capture do
        TraceSubject.new.nested_boom
      rescue ArgumentError
        nil
      end

      expect(failed.to_tree).to include("!! ArgumentError: kaboom")
    end

    it "says so when the capture was truncated" do
      capped = RailsTracepointStack.capture(max_traces: 2) { TraceSubject.new.deep(20) }

      expect(capped.to_tree).to include("truncated")
    end

    it "renders a class method with dot notation instead of its singleton class" do
      class_method = RailsTracepointStack.capture { TraceSubject.build(1) }

      expect(class_method.to_tree).to start_with("TraceSubject.build (")
    end

    it "leaves an anonymous singleton class alone instead of printing its address" do
      record = RailsTracepointStack::TraceRecord.new(
        kind: :call, class_name: "#<Class:0x00007f1234>", method_name: :whatever,
        file_path: "app/thing.rb", line_number: 3, params: {}, depth: 0
      )

      expect(RailsTracepointStack::Renderer::Tree.line_for(record))
        .to start_with("#<Class:0x00007f1234>#whatever ")
    end

    describe "compiled templates" do
      def template_record(params)
        RailsTracepointStack::TraceRecord.new(
          kind: :call,
          class_name: "#<Class:0x00007f1234>",
          method_name: :_app_views_orders_index_html_erb___123_456,
          file_path: "#{Dir.pwd}/app/views/orders/index.html.erb",
          line_number: 0,
          params: params,
          depth: 1
        )
      end

      it "renders the template path instead of the compiled method name" do
        line = RailsTracepointStack::Renderer::Tree.line_for(template_record({}))

        expect(line).to eq("  render app/views/orders/index.html.erb {}")
      end

      it "keeps the locals a partial was given" do
        line = RailsTracepointStack::Renderer::Tree
          .line_for(template_record({"local_assigns" => {"order" => 42}}))

        expect(line).to end_with(%({"order":42}))
      end

      it "drops the rendering internals that are not the developer's data" do
        line = RailsTracepointStack::Renderer::Tree.line_for(
          template_record({"local_assigns" => {}, "output_buffer" => "", "_" => "#<Proc>"})
        )

        expect(line).not_to include("output_buffer")
      end
    end

    it "ends with a summary line" do
      expect(lines.last).to eq("2 calls, 2 returns, 0 raises, 1 class")
    end
  end

  describe "#summary" do
    it "counts the events and the distinct classes" do
      expect(session.summary).to include(
        calls: 2, returns: 2, raises: 0, classes: 1, truncated: false
      )
    end
  end

  describe "#as_json" do
    it "carries one entry per trace" do
      expect(session.as_json[:traces].size).to eq(session.traces.size)
    end

    it "describes a call entry" do
      entry = session.as_json[:traces].first

      expect(entry).to include(
        kind: :call,
        class_name: "TraceSubject",
        method_name: :nested,
        depth: 0,
        params: {"value" => 3}
      )
      expect(entry[:file_path]).to start_with("spec/support/trace_subject.rb:")
    end

    it "carries the summary alongside the traces" do
      expect(session.as_json[:summary]).to eq(session.summary)
    end

    it "keeps a nil return value rather than dropping the key" do
      nil_session = RailsTracepointStack.capture { TraceSubject.new.nothing }
      entry = nil_session.as_json[:traces].find { |trace| trace[:kind] == :return }

      expect(entry).to have_key(:return_value)
      expect(entry[:return_value]).to be_nil
    end

    it "omits exception fields from a plain call" do
      entry = session.as_json[:traces].first

      expect(entry).not_to have_key(:exception_class)
    end
  end
end
