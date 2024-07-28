require 'spec_helper'

RSpec.describe RailsTracepointStack::TraceFilter do
  include RailsTracepointStack::TraceFilter
  
  before do
    initialize_gem_configuration!
  end

  context 'when trace matches an ignore pattern' do
    before do
      RailsTracepointStack.configure do |config|
        config.ignore_patterns << /ignore_pattern/
      end

      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])
      
      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')
    end

    let(:pattern_trace) do 
      instance_double(
        RailsTracepointStack::Trace, 
        file_path: 'some_path/ignore_pattern/some_file.rb'
      )
    end

    it 'ignores the trace' do
      expect(ignore_trace?(trace: pattern_trace)).to be true
    end
  end

  ## Flaky test, this one fails when running all tests, but works when running only this test

  context 'when trace does not meet any ignore criteria' do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])
      
      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')
    end

    let(:normal_trace) do 
      instance_double(RailsTracepointStack::Trace, 
      file_path: 'some_path/some_file.rb')
    end

    it 'does not ignore the trace' do
      expect(ignore_trace?(trace: normal_trace)).to be false
    end
  end

  context "when defined file path to filter patterns" do
    context "and trace not matches" do
      before do
        RailsTracepointStack.configure do |config|
          config.file_path_to_filter_patterns << /ignore_pattern/
        end

        allow(RailsTracepointStack::Filter::GemPath)
          .to receive(:full_gem_path)
          .and_return([])

        allow(RailsTracepointStack::Filter::RbConfig)
          .to receive(:ruby_lib_path)
          .and_return('/path/to/ruby/lib')
      end

      let(:pattern_trace) do 
        instance_double(
          RailsTracepointStack::Trace, 
          file_path: 'some_path/ignore_pattern/some_file.rb'
        )
      end

      it 'ignores the trace' do
        expect(ignore_trace?(trace: pattern_trace)).to be false
      end
    end

    context "and trace matches" do
      before do
        RailsTracepointStack.configure do |config|
          config.file_path_to_filter_patterns << /ignore_pattern/
        end

        allow(RailsTracepointStack::Filter::GemPath)
          .to receive(:full_gem_path)
          .and_return([])

        allow(RailsTracepointStack::Filter::RbConfig)
          .to receive(:ruby_lib_path)
          .and_return('/path/to/ruby/lib')
      end

      let(:pattern_trace) do 
        instance_double(
          RailsTracepointStack::Trace, 
          file_path: 'some_path/some_file.rb'
        )
      end

      it 'does not ignore the trace' do
        expect(ignore_trace?(trace: pattern_trace)).to be false
      end
    end
  end
end
