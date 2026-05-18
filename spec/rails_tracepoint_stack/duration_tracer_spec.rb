require "spec_helper"
require_relative "../../lib/rails_tracepoint_stack/duration_tracer"

class Foo
  def dummy_method
    nil
  end

  def dummy_method_with_params(param_1, param_2)
    nil
  end
end

RSpec.describe RailsTracepointStack::DurationTracer do
  let(:tracer) { RailsTracepointStack::DurationTracer.new }

  before do
    allow(RailsTracepointStack::TmpSave)
      .to receive(:save)
      .and_return(true)

    allow_any_instance_of(TracePoint)
      .to receive(:lineno).and_return(6)

    allow_any_instance_of(TracePoint)
      .to receive(:defined_class).and_return(Foo)

    allow_any_instance_of(TracePoint)
      .to receive(:method_id).and_return(:dummy_method)

    allow_any_instance_of(TracePoint)
      .to receive(:path).and_return("/stubbed/path/to/file.rb")
  end

  describe "when the log should not be ignored because not match any filter block" do
    before do
      allow(RailsTracepointStack::Filter::GemPath)
        .to receive(:full_gem_path)
        .and_return(["/another/path/to/gem"])

      allow(RailsTracepointStack::Filter::RbConfig)
        .to receive(:ruby_lib_path)
        .and_return("/path/to/ruby/lib")

      allow_any_instance_of(TracePoint)
        .to receive(:path)
        .and_return("/app/rails_tracepoint_stack/spec/tracer_spec.rb")

      allow_any_instance_of(RailsTracepointStack::Configuration)
        .to receive(:log_format)
        .and_return(:text)
    end

    it "calls logger with correct params" do
      tracer.enable do
        Foo.new.dummy_method
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::TmpSave)
        .to have_received(:save)
        .with(
          trace: an_instance_of(RailsTracepointStack::Trace),
          current_time: an_instance_of(Float),
          last_time: an_instance_of(Float)
        )
    end
  end
end
