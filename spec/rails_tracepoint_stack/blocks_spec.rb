require "spec_helper"

RSpec.describe "tracing blocks" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  def block_records(session)
    session.traces.select(&:block_call?)
  end

  describe "by default" do
    it "does not trace blocks" do
      session = RailsTracepointStack.capture { TraceSubject.new.calls_a_block }

      expect(block_records(session)).to be_empty
    end
  end

  describe "with blocks: true" do
    it "records the block" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.calls_a_block }

      expect(block_records(session)).not_to be_empty
    end

    it "keeps the arguments the block received" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.calls_a_block }

      expect(block_records(session).map(&:params)).to include({"value" => 7})
    end

    it "keeps what the block returned" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.calls_a_block }
      returned = session.traces.select(&:block_return?).map(&:return_value)

      expect(returned).to include(8)
    end

    it "nests the block under the method that called it" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.calls_a_block }
      outer = session.traces.find { |t| t.call? && t.method_name == :calls_a_block }

      expect(block_records(session).map(&:depth).min).to be > outer.depth
    end
  end

  describe "a block that runs once per element" do
    subject(:session) do
      RailsTracepointStack.capture(blocks: true) { TraceSubject.new.repeated_block }
    end

    it "collapses the repeats into a single record" do
      expect(block_records(session).size).to eq(1)
    end

    it "counts how many times it ran" do
      expect(block_records(session).first.repeats).to eq(5)
    end

    it "shows the count in the tree" do
      expect(session.to_tree).to match(/5× /)
    end

    it "does not leave the returns behind" do
      expect(session.traces.select(&:block_return?).size).to eq(1)
    end
  end

  describe "the block handed to capture" do
    before do
      RailsTracepointStack.configure do |config|
        config.file_path_to_filter_patterns = [%r{spec/rails_tracepoint_stack/blocks_spec}]
      end
    end

    it "is not part of the trace" do
      session = RailsTracepointStack.capture(blocks: true) { 1 + 1 }

      expect(session.traces).to be_empty
    end

    # The capture block only reaches this code when it lives in a traced file,
    # so both paths have to be watched for the phantom level to show up.
    it "does not take a level of depth with it" do
      RailsTracepointStack.configure do |config|
        config.file_path_to_filter_patterns = [
          %r{spec/support/trace_subject},
          %r{spec/rails_tracepoint_stack/blocks_spec}
        ]
      end

      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.add(1, 2) }

      expect(session.traces.map(&:depth).min).to eq(0)
    end

    it "does not hide blocks written on the same line" do
      session = RailsTracepointStack.capture(blocks: true) { [1].each { |n| } }

      expect(session.traces.select(&:block_call?).size).to eq(1)
    end
  end

  describe "naming" do
    it "names a block by the method it was written in" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.calls_a_block }

      expect(session.to_tree).to include("TraceSubject#calls_a_block { }")
    end

    it "falls back to the location for a block with no enclosing method" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.runs_scope_like(2) }
      line = session.to_tree.lines.find { |l| l.include?("block") }

      expect(line).to match(%r{block \{ \} \(spec/support/trace_subject\.rb:\d+\)})
    end

    it "still records what that block returned" do
      session = RailsTracepointStack.capture(blocks: true) { TraceSubject.new.runs_scope_like(2) }

      expect(session.traces.select(&:block_return?).map(&:return_value)).to include(6)
    end
  end
end
