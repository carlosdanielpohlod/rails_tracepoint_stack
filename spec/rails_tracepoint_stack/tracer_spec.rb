require 'spec_helper'

class Foo
  def dummy_method
    return
  end

  def dummy_method_with_params(param_1, param_2)
    return
  end
end

RSpec.describe RailsTracepointStack::Tracer do
  let(:tracer) { RailsTracepointStack::Tracer.new }

  before do
    allow(RailsTracepointStack::Logger)
      .to receive(:log)

    allow_any_instance_of(TracePoint)
      .to receive(:lineno).and_return(6)
  end

  describe "when the log should not be ignored because not match any filter block" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/another/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/app/rails_tracepoint_stack/spec/tracer_spec.rb")

      allow_any_instance_of(RailsTracepointStack::Configuration)
        .to receive(:log_format)
        .and_return(:text)
    end

    include_examples "tracer success examples asserts"
  end

  context "when the log should be ignored because is a gem dependency" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return([])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/path/to/ruby/lib")

      RailsTracepointStack.configure do |config|
        config.log_external_sources = false
      end
    end

    it 'does not call logger' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).not_to have_received(:log)
    end
  end

  context "when the log should be ignored because is a internal dependency" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/path/to/gem/some_file.rb")

      RailsTracepointStack.configure do |config|
        config.log_external_sources = false
      end
    end

    it 'does not call logger' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).not_to have_received(:log)
    end
  end

  context "when the log should not be ignored because is a external dependency" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/another/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/another/path/to/gem/some_file.rb")

      RailsTracepointStack.configure do |config|
        config.log_external_sources = true
      end
    end

    it 'calls logger' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).to have_received(:log)
    end
  end

  context "when the log attends a custom ignore pattern" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/another/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/another/path/to/gem/some_file.rb")

      RailsTracepointStack.configure do |config|
        config.ignore_patterns = [/another\/path/]
      end
    end

    it 'does not call logger' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).not_to have_received(:log)
    end
  end

  context "when the log attends a file_path_to_filter_patterns" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/another/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/another/path/some_file.rb")
        
      allow_any_instance_of(RailsTracepointStack::Trace)
        .to receive(:file_path)
        .and_return("/another/path/some_file.rb")
      
      RailsTracepointStack.configure do |config|
        config.file_path_to_filter_patterns = [/another\/path/]
      end
    end

    it "calls logger" do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).to have_received(:log)
    end
  end
end
