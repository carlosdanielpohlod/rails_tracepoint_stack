require 'spec_helper'

RSpec.describe RailsTracepointStack::Filter::TraceFromRubyCodeFilter do
  describe '.should_ignore_because_is_ruby_trace?' do
    let(:trace) { double('trace') }

    before do
      allow(RailsTracepointStack.configuration).to receive(:log_external_sources).and_return(log_external_sources)
    end

    context 'when log_external_sources is true' do
      let(:log_external_sources) { true }

      it 'does not ignore any traces' do
        allow(trace).to receive(:file_path).and_return('<internal:kernel>')
        expect(described_class.should_ignore_because_is_ruby_trace?(trace: trace)).to be false
      end
    end

    context 'when log_external_sources is false' do
      let(:log_external_sources) { false }

      it 'ignores internal and eval traces' do
        allow(trace).to receive(:file_path).and_return('<internal:kernel>')
        expect(described_class.should_ignore_because_is_ruby_trace?(trace: trace)).to be true

        allow(trace).to receive(:file_path).and_return('(eval)')
        expect(described_class.should_ignore_because_is_ruby_trace?(trace: trace)).to be true
      end
    end
  end
end
