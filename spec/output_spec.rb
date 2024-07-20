require 'rails_tracepoint_stack/output'

RSpec.describe RailsTracepointStack::Output do
  describe '.log' do
    it 'logs the trace information' do
      trace_double = instance_double("Trace", 
                                     class_name: "MyClass", 
                                     method_id: :my_method, 
                                     file_path: "/path/to/file.rb", 
                                     line_number: 42, 
                                     params: { key: 'value' })

      allow(RailsTracepointStack::Logger).to receive(:log)

      # Chama o método .log
      described_class.log(trace: trace_double)

      
      expected_log_message = "called: MyClass#my_method in /path/to/file.rb:42 with params: {:key=>\"value\"}"
      expect(RailsTracepointStack::Logger).to have_received(:log).with(expected_log_message)
    end
  end
end
