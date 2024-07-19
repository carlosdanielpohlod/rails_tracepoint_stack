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
    end

    it 'calls logger with correct log' do
      tracer.tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger)
        .to have_received(:log)
        .with(/called: Foo#dummy_method/)
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
