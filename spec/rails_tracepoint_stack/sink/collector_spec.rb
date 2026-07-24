require "spec_helper"

RSpec.describe RailsTracepointStack::Sink::Collector do
  subject(:collector) { described_class.new }

  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  def trace(events: [:call, :return, :raise], &block)
    tracer = RailsTracepointStack::Tracer.new(sink: collector, events: events)
    tracer.enable(&block)
    collector.session
  end

  def record_for(session, kind, method_name)
    session.traces.find { |record| record.kind == kind && record.method_name == method_name }
  end

  it "keeps the traces after the tracepoint is gone" do
    session = trace { TraceSubject.new.add(1, 2) }

    expect(session.traces).not_to be_empty
  end

  it "snapshots where the call happened" do
    session = trace { TraceSubject.new.add(1, 2) }
    record = record_for(session, :call, :add)

    expect(record.class_name).to eq("TraceSubject")
    expect(record.file_path).to end_with("spec/support/trace_subject.rb")
    expect(record.line_number).to be_a(Integer)
  end

  it "snapshots params as plain values" do
    session = trace { TraceSubject.new.add(1, 2) }

    expect(record_for(session, :call, :add).params).to eq({"first" => 1, "second" => 2})
  end

  it "snapshots the return value" do
    session = trace { TraceSubject.new.add(1, 2) }

    expect(record_for(session, :return, :add).return_value).to eq(3)
  end

  it "snapshots the exception class and message" do
    session = trace do
      begin
        TraceSubject.new.boom
      rescue ArgumentError
        nil
      end
    end
    record = record_for(session, :raise, :boom)

    expect(record.exception_class).to eq("ArgumentError")
    expect(record.exception_message).to eq("kaboom")
  end

  it "does not hold on to the traced objects" do
    mutable = +"before"
    session = trace { TraceSubject.new.add(mutable, "!") }
    mutable << " mutated"

    expect(record_for(session, :call, :add).params["first"]).to eq("before")
  end
end
