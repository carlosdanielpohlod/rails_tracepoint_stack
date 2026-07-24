require "spec_helper"

RSpec.describe RailsTracepointStack::Tracer do
  let(:sink) { RecordingSink.new }

  # This gem is itself a Bundler spec, so its own files look like a dependency
  # to the filters. Whitelisting the support file is the same config a host app
  # would use to narrow tracing to one file.
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  describe "sink injection" do
    it "hands every traced call to the given sink" do
      tracer = described_class.new(sink: sink)

      tracer.enable { TraceSubject.new.add(1, 2) }

      expect(sink.kinds_for(:add)).to eq([:call])
    end

    it "keeps params on the trace it hands over" do
      tracer = described_class.new(sink: sink)

      tracer.enable { TraceSubject.new.add(1, 2) }

      expect(sink.records.first.params).to eq({first: 1, second: 2})
    end
  end

  describe "depth when returns are not watched" do
    # This is how the global tracer runs: it only ever sees :call, so nothing
    # ever pops a frame off the back of a return event.
    it "keeps sibling calls at the same depth" do
      tracer = described_class.new(sink: sink, events: [:call])

      tracer.enable do
        5.times { TraceSubject.new.add(1, 2) }
      end

      expect(sink.records.map(&:depth)).to all(eq(0))
    end

    it "still nests a call made inside another one" do
      tracer = described_class.new(sink: sink, events: [:call])

      tracer.enable { TraceSubject.new.nested(3) }

      expect(sink.records.map { |record| [record.method_name, record.depth] })
        .to eq([[:nested, 0], [:doubled, 1]])
    end
  end

  describe "watched events" do
    it "does not watch returns by default" do
      tracer = described_class.new(sink: sink)

      tracer.enable { TraceSubject.new.add(1, 2) }

      expect(sink.kinds_for(:add)).not_to include(:return)
    end

    it "watches returns when asked to" do
      tracer = described_class.new(sink: sink, events: [:call, :return])

      tracer.enable { TraceSubject.new.add(1, 2) }

      expect(sink.kinds_for(:add)).to eq([:call, :return])
    end

    it "watches raises when asked to" do
      tracer = described_class.new(sink: sink, events: [:call, :raise])

      tracer.enable do
        TraceSubject.new.boom
      rescue ArgumentError
        nil
      end

      expect(sink.kinds_for(:boom)).to eq([:call, :raise])
    end
  end
end
