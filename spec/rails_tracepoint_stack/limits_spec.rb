require "spec_helper"

RSpec.describe "capture limits" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  def call_record(session, method_name)
    session.traces.find { |record| record.call? && record.method_name == method_name }
  end

  describe "max_traces" do
    it "stops collecting once the cap is reached" do
      session = RailsTracepointStack.capture(max_traces: 4) { TraceSubject.new.deep(20) }

      expect(session.traces.size).to eq(4)
    end

    it "marks the session as truncated" do
      session = RailsTracepointStack.capture(max_traces: 4) { TraceSubject.new.deep(20) }

      expect(session).to be_truncated
    end

    it "is not truncated when everything fit" do
      session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

      expect(session).not_to be_truncated
    end
  end

  describe "max_depth" do
    it "drops traces deeper than the limit" do
      session = RailsTracepointStack.capture(max_depth: 1) { TraceSubject.new.deep(5) }

      expect(session.traces.map(&:depth).max).to eq(1)
    end

    it "keeps the shallow traces" do
      session = RailsTracepointStack.capture(max_depth: 1) { TraceSubject.new.deep(5) }

      expect(session.traces.map(&:depth)).to include(0)
    end
  end

  describe "value truncation" do
    it "shortens long strings" do
      session = RailsTracepointStack.capture(max_string_length: 10) do
        TraceSubject.new.echo("a" * 50)
      end

      expect(call_record(session, :echo).params["value"]).to eq("aaaaaaaaaa… (50 chars)")
    end

    it "leaves short strings alone" do
      session = RailsTracepointStack.capture(max_string_length: 10) do
        TraceSubject.new.echo("short")
      end

      expect(call_record(session, :echo).params["value"]).to eq("short")
    end

    it "shortens long arrays" do
      session = RailsTracepointStack.capture(max_collection_size: 3) do
        TraceSubject.new.echo([1, 2, 3, 4, 5])
      end

      expect(call_record(session, :echo).params["value"]).to eq([1, 2, 3, "(+2 more)"])
    end

    it "shortens long hashes" do
      session = RailsTracepointStack.capture(max_collection_size: 2) do
        TraceSubject.new.echo({a: 1, b: 2, c: 3})
      end

      expect(call_record(session, :echo).params["value"])
        .to eq({"a" => 1, "b" => 2, "…" => "(+1 more)"})
    end

    it "truncates values nested inside collections" do
      session = RailsTracepointStack.capture(max_string_length: 4) do
        TraceSubject.new.echo({name: "abcdefgh"})
      end

      expect(call_record(session, :echo).params["value"]).to eq({"name" => "abcd… (8 chars)"})
    end
  end

  describe "switching data off" do
    it "skips params when asked" do
      session = RailsTracepointStack.capture(capture_params: false) do
        TraceSubject.new.add(1, 2)
      end

      expect(call_record(session, :add).params).to eq({})
    end

    it "skips return values when asked" do
      session = RailsTracepointStack.capture(capture_return: false) do
        TraceSubject.new.add(1, 2)
      end

      returned = session.traces.find { |record| record.return? && record.method_name == :add }

      expect(returned.return_value).to be_nil
    end
  end
end
