require "spec_helper"

RSpec.describe "values that are not UTF-8" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  # A JPEG header: bytes that are valid nowhere in UTF-8. Anything reading a
  # file in binary mode, hashing, or holding a response body produces these.
  let(:binary) { "\xFF\xD8\xFF\xE0JFIF".dup.force_encoding(Encoding::BINARY) }
  # Bytes that happen to be ASCII, so only the encoding tag is wrong.
  let(:ascii_tagged_binary) { "plain bytes".dup.force_encoding(Encoding::BINARY) }
  # Tagged UTF-8, but holding a byte sequence that is not valid UTF-8.
  let(:broken_utf8) { "caf\xC3".dup.force_encoding(Encoding::UTF_8) }

  def capture_echo(value)
    RailsTracepointStack.capture { TraceSubject.new.echo(value) }
  end

  describe "#to_tree" do
    it "renders a binary argument instead of raising" do
      expect { capture_echo(binary).to_tree }.not_to raise_error
    end

    it "renders binary bytes that happen to be ASCII" do
      expect(capture_echo(ascii_tagged_binary).to_tree).to include("plain bytes")
    end

    it "renders a string tagged UTF-8 that holds invalid bytes" do
      expect { capture_echo(broken_utf8).to_tree }.not_to raise_error
    end

    it "produces a tree that is valid UTF-8" do
      tree = capture_echo(binary).to_tree

      expect(tree.encoding).to eq(Encoding::UTF_8)
      expect(tree).to be_valid_encoding
    end
  end

  describe "#to_json" do
    it "serializes a binary argument instead of raising" do
      expect { capture_echo(binary).to_json }.not_to raise_error
    end
  end

  describe "the text log format" do
    it "formats a binary argument instead of raising" do
      expect { RailsTracepointStack::LogFormatter.text_value(binary) }.not_to raise_error
    end
  end

  it "leaves a normal UTF-8 string untouched" do
    tree = capture_echo("olá, mundo — çãé").to_tree

    expect(tree).to include("olá, mundo — çãé")
  end
end
