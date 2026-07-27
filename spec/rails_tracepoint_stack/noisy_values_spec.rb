require "spec_helper"
require "json"

RSpec.describe "values that would swamp the output" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  describe "a class whose singleton class prints more than its name" do
    subject(:tree) do
      RailsTracepointStack.capture { NoisySingletonSubject.build(2) }.to_tree
    end

    it "renders the call as plain dot notation" do
      expect(tree).to start_with("NoisySingletonSubject.build ")
    end

    it "leaves the noise out of the line" do
      expect(tree).not_to include("load_schema")
    end
  end

  describe "a return value too large to be worth printing" do
    subject(:session) do
      RailsTracepointStack.capture(max_value_length: 300) do
        NoisySingletonSubject.many_objects
      end
    end

    let(:returned) do
      session.traces.find { |record| record.return? && record.method_name == :many_objects }
    end

    it "replaces the value with something that fits the limit" do
      expect(JSON.generate(returned.return_value).length).to be <= 300
    end

    it "says how many items were dropped" do
      expect(returned.return_value.to_s).to include("80 items")
    end

    it "says which limit cut it" do
      expect(returned.return_value.to_s).to include("max_value_length")
    end

    it "keeps a small value untouched" do
      small = RailsTracepointStack.capture(max_value_length: 300) do
        TraceSubject.new.add(1, 2)
      end
      record = small.traces.find { |trace| trace.return? && trace.method_name == :add }

      expect(record.return_value).to eq(3)
    end
  end
end
