# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

RSpec.describe RailsTracepointStack::TraceFilter do
  before do
    initialize_gem_configuration!
  end

  context 'when trace is from internal sources' do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')
    end

    let(:internal_trace) do
      instance_double(RailsTracepointStack::Trace, file_path: '<internal:kernel>')
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: internal_trace)).to be true
    end
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
      expect(described_class.ignore_trace?(trace: pattern_trace)).to be true
    end
  end

  ## Flaky test, this one fails when running all tests, but works when running only this test
  context 'when trace is from a gem path' do
    let(:gem_path_trace) do
      instance_double(RailsTracepointStack::Trace,
                      file_path: '/path/to/gem/some_file.rb')
    end

    before do
      allow_any_instance_of(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: gem_path_trace)).to be true
    end
  end

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
      expect(described_class.ignore_trace?(trace: normal_trace)).to be false
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
    end

    it 'ignores the trace' do
      expect(described_class.ignore_trace?(trace: ruby_lib_trace)).to be true
    end
  end

  context 'when defined file path to filter patterns' do
    context 'and trace not matches' do
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
        expect(described_class.ignore_trace?(trace: pattern_trace)).to be false
      end
    end

    context 'and trace matches' do
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
        expect(described_class.ignore_trace?(trace: pattern_trace)).to be true
      end
    end
  end
end
