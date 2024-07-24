require "spec_helper"
require "fileutils"

RSpec.describe RailsTracepointStack::Logger do
  let(:log_message) { "This is a test log message." }
  let(:log_file_path) { "log/rails_tracepoint_stack.log" }
  context "when provide a custom logger" do
    let(:custom_logger) { double("Logger", info: true) }
    before do
      RailsTracepointStack.configure do |config|
        config.logger = custom_logger
      end
    end

    it "uses the custom logger to log the message" do
      described_class.log(log_message)

      expect(custom_logger)
        .to have_received(:info)
        .with(log_message)
    end
  end

  context "when no custom logger is provided" do
    before do
      RailsTracepointStack.configure do |config|
        config.logger = nil
      end

      allow(File)
        .to receive(:open)
        .with("log/rails_tracepoint_stack.log", "a")
    end

    it "logs the message to the default log file" do
      described_class.log(log_message)

      expect(File).to have_received(:open)
    end
  end
end
