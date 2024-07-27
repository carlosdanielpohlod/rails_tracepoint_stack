require 'spec_helper'

RSpec.describe RailsTracepointStack::Filter::TraceFromDependenciesFilter do
  context 'when trace is from ruby_lib_path' do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow(RailsTracepointStack.configuration)
        .to receive(:log_external_sources)
        .and_return(false)
    end

    let(:internal_trace) do 
      instance_double(RailsTracepointStack::Trace, 
        file_path: '/path/to/ruby/lib'
      )
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: internal_trace)).to be true
    end
  end

  context 'when trace is from a gem path' do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow(RailsTracepointStack.configuration)
        .to receive(:log_external_sources)
        .and_return(false)
    end

    let(:gem_path_trace) do
      instance_double(RailsTracepointStack::Trace, 
        file_path: '/path/to/gem/some_file.rb'
      )
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: gem_path_trace))
        .to be true
    end
  end

  context 'when trace is from a ruby lib path' do
    let(:ruby_lib_trace) do
      instance_double(RailsTracepointStack::Trace, 
      file_path: '/path/to/ruby/lib/some_file.rb')
    end

    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')
      
      allow(RailsTracepointStack.configuration)
        .to receive(:log_external_sources)
        .and_return(false)
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: ruby_lib_trace)).to be true
    end
  end

  context "when not ignore external sources" do
    let(:external_trace) do
      instance_double(RailsTracepointStack::Trace, 
        file_path: '/path/to/external/source/some_file.rb'
      )
    end

    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow(RailsTracepointStack.configuration)
        .to receive(:log_external_sources)
        .and_return(true)
    end

    it 'does not ignore the trace' do
      expect(described_class.ignore_trace?(trace: external_trace)).to be false
    end
  end
end
