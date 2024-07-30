require 'spec_helper'

RSpec.describe RailsTracepointStack::Filter::TraceToIgnoreFilter do
  include RailsTracepointStack::Filter::TraceToIgnoreFilter

  describe '.attends_some_custom_pattern_to_ignore?' do
    let(:trace) { double('trace', file_path: file_path) }

    before do
      allow(RailsTracepointStack.configuration).to receive(:ignore_patterns).and_return(ignore_patterns)
    end

    context 'when the trace file path matches an ignore pattern' do
      let(:ignore_patterns) { [/ignored_path/, /secret/] }
      let(:file_path) { '/some/ignored_path/file.rb' }

      it 'returns true' do
        expect(attends_some_custom_pattern_to_ignore?(trace: trace)).to be true
      end
    end

    context 'when the trace file path does not match any ignore pattern' do
      let(:ignore_patterns) { [/ignored_path/, /secret/] }
      let(:file_path) { '/some/regular_path/file.rb' }

      it 'returns false' do
        expect(attends_some_custom_pattern_to_ignore?(trace: trace)).to be false
      end
    end

    context 'with multiple ignore patterns' do
      let(:ignore_patterns) { [/ignored_path/, /another_path/, /secret/] }

      it 'returns true if the trace file path matches any pattern' do
        expect(attends_some_custom_pattern_to_ignore?(trace: double('trace', file_path: '/another_path/file.rb'))).to be true
        expect(attends_some_custom_pattern_to_ignore?(trace: double('trace', file_path: '/some/secret/file.rb'))).to be true
      end

      it 'returns false if the trace file path does not match any pattern' do
        expect(attends_some_custom_pattern_to_ignore?(trace: double('trace', file_path: '/unmatched_path/file.rb'))).to be false
      end
    end
  end
end
