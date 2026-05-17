require "spec_helper"
require "json"

RSpec.describe RailsTracepointStack::LogFormatter do
  let(:trace_double) do
    instance_double(RailsTracepointStack::Trace,
      class_name: "MyClass",
      method_name: :my_method,
      file_path: "/path/to/file.rb",
      line_number: 42,
      params: {key: "value"})
  end

  describe ".message" do
    context "when format is :json" do
      before do
        allow(RailsTracepointStack)
          .to receive_message_chain(:configuration, :log_format)
          .and_return(:json)
      end

      it "returns a JSON formatted string" do
        expected_json = {
          class: "MyClass",
          method_name: :my_method,
          path: "/path/to/file.rb",
          line: 42,
          params: {key: "value"}
        }.to_json

        expect(described_class.message(trace_double)).to eq(expected_json)
      end
    end

    context "when format is not :json" do
      before do
        allow(RailsTracepointStack)
          .to receive_message_chain(:configuration, :log_format)
          .and_return(nil)
      end

      it "returns a text formatted string" do
        expected_text = "called: MyClass#my_method in /path/to/file.rb:42 with params: {:key=>\"value\"}"
        expect(described_class.message(trace_double)).to eq(expected_text)
      end
    end
  end

  describe ".text" do
    it "returns a text formatted string" do
      expected_text = "called: MyClass#my_method in /path/to/file.rb:42 with params: {:key=>\"value\"}"
      expect(described_class.text(trace_double)).to eq(expected_text)
    end
  end

  describe ".json" do
    it "returns a JSON formatted string" do
      expected_json = {
        class: "MyClass",
        method_name: :my_method,
        path: "/path/to/file.rb",
        line: 42,
        params: {key: "value"}
      }.to_json

      expect(described_class.json(trace_double)).to eq(expected_json)
    end

    it "serializes recursive params without blowing the stack" do
      recursive_payload = {}
      recursive_payload[:self] = recursive_payload

      allow(trace_double)
        .to receive(:params)
        .and_return({payload: recursive_payload})

      parsed_json = JSON.parse(described_class.json(trace_double))

      expect(parsed_json.fetch("params")).to eq(
        "payload" => {
          "self" => "[recursive Hash]"
        }
      )
    end

    it "falls back when a param inspect raises SystemStackError" do
      exploding_object = Class.new do
        def inspect
          raise SystemStackError, "stack level too deep"
        end
      end.new

      allow(trace_double)
        .to receive(:params)
        .and_return({payload: exploding_object})

      parsed_json = JSON.parse(described_class.json(trace_double))

      expect(parsed_json.fetch("params")).to eq(
        "payload" => "#<#{exploding_object.class} unserializable: SystemStackError: stack level too deep>"
      )
    end
  end
end
