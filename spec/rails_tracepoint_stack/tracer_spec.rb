# frozen_string_literal: true

require 'spec_helper'

class Foo
  def dummy_method
    nil
  end

  def dummy_method_with_params(_param_1, _param_2)
    nil
  end
end

RSpec.describe RailsTracepointStack::Tracer do
  let(:tracer) { RailsTracepointStack::Tracer.new }

  context 'when the log not should be ignored' do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(['/another/path/to/gem'])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return('/path/to/ruby/lib')

      allow(RailsTracepointStack::Logger).to receive(:log)

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return('/app/rails_tracepoint_stack/spec/tracer_spec.rb')

      allow_any_instance_of(TracePoint).to receive(:lineno).and_return(6)

      allow_any_instance_of(RailsTracepointStack::Configuration)
        .to receive(:log_format)
        .and_return(:text)
    end

    context 'when log format is text' do
      before do
        RailsTracepointStack.configure do |config|
          config.log_format = :text
        end
      end

      it 'calls logger with correct log' do
        tracer.tracer.enable do
          Foo.new.dummy_method
        end

        expect(RailsTracepointStack::Logger)
          .to have_received(:log)
          .with('called: Foo#dummy_method in /app/rails_tracepoint_stack/spec/tracer_spec.rb:6 with params: {}')
      end
    end

    context 'when log format is json' do
      before do
        RailsTracepointStack.configure do |config|
          config.log_format = :json
        end
      end
      # TODO: Extract this test to a proper place
      it 'calls logger with correct log with json log format' do
        allow_any_instance_of(RailsTracepointStack::Configuration)
          .to receive(:log_format)
          .and_return(:json)

        tracer.tracer.enable do
          Foo.new.dummy_method
        end

        expect(RailsTracepointStack::Logger)
          .to have_received(:log)
          .with('{"class":"Foo","method_name":"dummy_method","path":"/app/rails_tracepoint_stack/spec/tracer_spec.rb","line":6,"params":{}}')
      end

      # TODO: Extract this test to a proper place
      it 'calls logger with correct log with json log format' do
        allow_any_instance_of(RailsTracepointStack::Configuration).to receive(:log_format).and_return(:json)

        tracer.tracer.enable do
          Foo.new.dummy_method_with_params('param_1_value', 'param_2_value')
        end

        expect(RailsTracepointStack::Logger)
          .to have_received(:log)
          .with('{"class":"Foo","method_name":"dummy_method_with_params","path":"/app/rails_tracepoint_stack/spec/tracer_spec.rb","line":6,"params":{"param_1":"param_1_value","param_2":"param_2_value"}}')
      end
    end
  end

  context 'when the log should be ignored' do
    before do
      allow(RailsTracepointStack::TraceFilter)
        .to receive(:ignore_trace?)
        .and_return(true)

      allow(RailsTracepointStack::Logger).to receive(:log)
    end

    it 'does not call logger' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger).not_to have_received(:log)
    end
  end
end
