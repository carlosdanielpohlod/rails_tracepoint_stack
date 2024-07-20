require 'rails_tracepoint_stack/log_formatter'
require 'json'
require 'rails_tracepoint_stack/trace'

RSpec.describe RailsTracepointStack::LogFormatter do
  let(:trace_double) do
    instance_double(RailsTracepointStack::Trace, 
                    class_name: "MyClass", 
                    method_name: :my_method, 
                    file_path: "/path/to/file.rb", 
                    line_number: 42, 
                    params: { key: 'value' })
  end

  describe '.message' do
    context 'when format is :json' do
      before do
        allow(RailsTracepointStack)
          .to receive_message_chain(:configuration, :log_format)
          .and_return(:json)
      end

      it 'returns a JSON formatted string' do
        expected_json = {
          class: "MyClass",
          method_name: :my_method,
          path: "/path/to/file.rb",
          line: 42,
          params: { key: 'value' }
        }.to_json

        expect(described_class.message(trace_double)).to eq(expected_json)
      end
    end

    context 'when format is not :json' do
      before do
        allow(RailsTracepointStack)
        .to receive_message_chain(:configuration, :log_format)
        .and_return(nil)
      end

      it 'returns a text formatted string' do
        expected_text = "called: MyClass#my_method in /path/to/file.rb:42 with params: {:key=>\"value\"}"
        expect(described_class.message(trace_double)).to eq(expected_text)
      end
    end
  end

  describe '.text' do
    it 'returns a text formatted string' do
      expected_text = "called: MyClass#my_method in /path/to/file.rb:42 with params: {:key=>\"value\"}"
      expect(described_class.text(trace_double)).to eq(expected_text)
    end
  end

  describe '.json' do
    it 'returns a JSON formatted string' do
      expected_json = {
        class: "MyClass",
        method_name: :my_method,
        path: "/path/to/file.rb",
        line: 42,
        params: { key: 'value' }
      }.to_json

      expect(described_class.json(trace_double)).to eq(expected_json)
    end
  end
end
