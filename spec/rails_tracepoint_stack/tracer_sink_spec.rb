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
        begin
          TraceSubject.new.boom
        rescue ArgumentError
          nil
        end
      end

      expect(sink.kinds_for(:boom)).to eq([:call, :raise])
    end
  end
end
