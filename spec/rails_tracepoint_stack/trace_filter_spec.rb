require 'rails_tracepoint_stack'
require 'rails_tracepoint_stack/trace_filter'
require 'rspec'
require 'bundler'
require 'ostruct'

RSpec.describe RailsTracepointStack::TraceFilter do
  before(:all) do
    RailsTracepointStack.configure do |config|
      config.ignore_patterns << /ignore_pattern/
    end
  end

  context 'when trace is from internal sources' do
    let(:internal_trace) { OpenStruct.new(path: '<internal:kernel>') }

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: internal_trace)).to be true
    end
  end

  context 'when trace matches an ignore pattern' do
    let(:pattern_trace) { OpenStruct.new(path: 'some_path/ignore_pattern/some_file.rb') }

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: pattern_trace)).to be true
    end
  end

  context 'when trace does not meet any ignore criteria' do
    let(:normal_trace) { OpenStruct.new(path: 'some_path/some_file.rb') }

    it 'does not ignore the trace' do
      expect(described_class.ignore_trace?(trace: normal_trace)).to be false
    end
  end
end
