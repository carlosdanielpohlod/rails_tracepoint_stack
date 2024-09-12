RSpec.shared_examples "tracer success examples asserts" do
  context "when log format is text" do
    it 'calls logger with correct log' do
      tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger)
        .to have_received(:log)
        .with("called: Foo#dummy_method in /app/rails_tracepoint_stack/spec/tracer_spec.rb:6 with params: {}")
    end
  end

  context "when log format is json" do
    before do
      allow(RailsTracepointStack.configuration)
        .to receive(:log_format)
        .and_return(:json)
    end
    # TODO: Extract this test to a proper place
    it 'calls logger with correct log with json log format' do
      tracer.enable do
        Foo.new.dummy_method
      end

      expect(RailsTracepointStack::Logger)
        .to have_received(:log)
        .with("{\"class\":\"Foo\",\"method_name\":\"dummy_method\",\"path\":\"/app/rails_tracepoint_stack/spec/tracer_spec.rb\",\"line\":6,\"params\":{}}")
    end
  end
end
