require "spec_helper"

RSpec.describe RailsTracepointStack::Filter::GemPath do
  around do |example|
    described_class.instance_variable_set(:@full_gem_path, nil)
    example.run
    described_class.instance_variable_set(:@full_gem_path, nil)
  end

  it "lists the gem paths of the current bundle" do
    expect(described_class.full_gem_path).to include(a_string_matching(/rspec/))
  end

  context "when Bundler is not loaded" do
    before { hide_const("Bundler") }

    it "does not blow up" do
      expect { described_class.full_gem_path }.not_to raise_error
    end

    it "still finds installed gem paths to filter against" do
      expect(described_class.full_gem_path).not_to be_empty
    end
  end
end
