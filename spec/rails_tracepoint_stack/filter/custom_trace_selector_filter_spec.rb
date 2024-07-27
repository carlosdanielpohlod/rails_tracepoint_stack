require 'spec_helper'

RSpec.describe RailsTracepointStack::Filter::CustomTraceSelectorFilter do
  describe '.ignore_trace?' do
    subject { described_class.ignore_trace?(trace: trace) }
    context "when the trace's file path matches a custom pattern" do
      let(:file_path) { 'app/controllers/posts_controller' }
      let(:trace) { instance_double(RailsTracepointStack::Trace, file_path: file_path) }

      before do
        allow(RailsTracepointStack.configuration).to receive(:file_path_to_filter_patterns).and_return([/app\/controllers/])
      end

      it { is_expected.to be_falsey }
    end
   
    context "when the trace's file path does not match a custom pattern" do
      let(:file_path) { 'app/models/post.rb' }
      let(:trace) { instance_double(RailsTracepointStack::Trace, file_path: file_path) }

      before do
        allow(RailsTracepointStack.configuration).to receive(:file_path_to_filter_patterns).and_return([/app\/controllers/])
      end

      it { is_expected.to be_truthy }
    end
  end
end 
