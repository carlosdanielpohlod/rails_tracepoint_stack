require "spec_helper"

RSpec.describe RailsTracepointStack::Trace do
  let(:trace_point_double) do
    instance_double("TracePoint",
      event: :call,
      defined_class: "MyClass",
      method_id: :my_method,
      path: "/path/to/file.rb",
      lineno: 42,
      binding: instance_double(
        "Binding",
        local_variables: ["var"],
        local_variable_get: "value"
      ))
  end
  let(:params) { {"var" => "value"} }
  subject(:trace) { described_class.new(trace_point: trace_point_double) }

  describe "#initialize" do
    it "initializes with trace_point and params" do
      expect(trace.params).to eq(params)
    end
  end

  describe "delegated methods" do
    it "returns the class name" do
      expect(trace.class_name).to eq("MyClass")
    end

    it "returns the method name" do
      expect(trace.method_name).to eq(:my_method)
    end

    it "returns the file path" do
      expect(trace.file_path).to eq("/path/to/file.rb")
    end

    it "returns the line number" do
      expect(trace.line_number).to eq(42)
    end
  end

  describe "event kinds" do
    def traces_for(&block)
      collected = []
      tracepoint = TracePoint.new(:call, :return, :raise) do |trace_point|
        next unless trace_point.defined_class == TraceSubject

        trace = described_class.new(trace_point: trace_point)
        collected << TraceEntry.new(
          trace.kind, trace.params, trace.return_value, trace.exception, trace.method_name
        )
      end
      tracepoint.enable(&block)
      collected
    end

    def entry_for(kind, method_name, &block)
      traces_for(&block).find { |entry| entry.kind == kind && entry.method_name == method_name }
    end

    it "marks a method entry as a call and exposes its params" do
      entry = entry_for(:call, :add) { TraceSubject.new.add(1, 2) }

      expect(entry.params).to eq({first: 1, second: 2})
    end

    it "marks a method exit as a return and exposes its value" do
      entry = entry_for(:return, :add) { TraceSubject.new.add(1, 2) }

      expect(entry.return_value).to eq(3)
    end

    it "does not collect params for a return event" do
      entry = entry_for(:return, :add) { TraceSubject.new.add(1, 2) }

      expect(entry.params).to eq({})
    end

    it "marks a raised error and exposes the exception" do
      entry = entry_for(:raise, :boom) do
        begin
          TraceSubject.new.boom
        rescue ArgumentError
          nil
        end
      end

      expect(entry.exception).to be_a(ArgumentError)
      expect(entry.exception.message).to eq("kaboom")
    end

    it "has no exception for a plain call" do
      entry = entry_for(:call, :add) { TraceSubject.new.add(1, 2) }

      expect(entry.exception).to be_nil
    end
  end
end
