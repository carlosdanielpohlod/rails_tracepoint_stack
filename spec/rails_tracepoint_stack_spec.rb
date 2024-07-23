require 'spec_helper'

RSpec.describe RailsTracepointStack do
  describe '.configure' do
    it 'initialize the default configuration attributes' do
      expect(described_class.configuration.file_path_to_filter_patterns).to eq([])
      expect(described_class.configuration.ignore_patterns).to eq([])
      expect(described_class.configuration.log_format).to eq(:text)
      expect(described_class.configuration.log_external_sources).to eq(false)
      expect(described_class.configuration.logger).to eq(nil)
    end
  end
end
