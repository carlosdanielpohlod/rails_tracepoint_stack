require 'spec_helper'
require_relative '../lib/rails_tracepoint_stack/trace.rb' 

RSpec.describe RailsTracepointStack::Trace do
  let(:trace_point_double) do
    instance_double("TracePoint", 
                    defined_class: "MyClass", 
                    method_id: :my_method, 
                    path: "/path/to/file.rb", 
                    lineno: 42)
  end
  let(:params) { { key: 'value' } }
  subject(:trace) { described_class.new(trace_point: trace_point_double, params: params) }

  describe '#initialize' do
    it 'initializes with trace_point and params' do
      expect(trace.params).to eq(params)
    end
  end

  describe 'delegated methods' do
    it 'returns the class name' do
      expect(trace.class_name).to eq("MyClass")
    end

    it 'returns the method name' do
      expect(trace.method_name).to eq(:my_method)
    end

    it 'returns the file path' do
      expect(trace.file_path).to eq("/path/to/file.rb")
    end

    it 'returns the line number' do
      expect(trace.line_number).to eq(42)
    end
  end
end
