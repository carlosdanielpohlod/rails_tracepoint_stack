require 'spec_helper'
require 'rails_tracepoint_stack'
require 'rails_tracepoint_stack/tracer'

class Foo
  def dummy_method
    return
  end
end

RSpec.describe RailsTracepointStack::Tracer do
  let(:tracer) { RailsTracepointStack::Tracer.new }

  context "when the log not should be ignored" do
    before do
      allow(RailsTracepointStack::TraceFilter)
        .to receive(:ignore_trace?)
        .and_return(false)

      allow(RailsTracepointStack::Logger).to receive(:log)

      allow_any_instance_of(TracePoint).to receive(:path).and_return("/app/rails_tracepoint_stack/spec/tracer_spec.rb")
      allow_any_instance_of(TracePoint).to receive(:lineno).and_return(6)
    end

    it 'calls logger with correct log' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger)
        .to have_received(:log)
        .with("called: Foo#dummy_method in /app/rails_tracepoint_stack/spec/tracer_spec.rb:6 with params: {}")
    end

    # TODO: Extract this test to a proper place
    it 'calls logger with correct log with json log format' do
      allow_any_instance_of(RailsTracepointStack::Configuration).to receive(:log_format).and_return(:json)

      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger)
        .to have_received(:log)
        .with("{\"class\":\"Foo\",\"method_id\":\"dummy_method\",\"path\":\"/app/rails_tracepoint_stack/spec/tracer_spec.rb\",\"line\":6,\"params\":{}}")
    end
  end

  context "when the log should be ignored" do
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
