require "spec_helper"

# Defined here on purpose: this file is not whitelisted, so the filters treat
# it as external code, the same way they treat a gem.
def method_the_filters_drop
  1 + 1
end

RSpec.describe "reporting what the filters dropped" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  it "counts the traces it dropped" do
    session = RailsTracepointStack.capture { method_the_filters_drop }

    expect(session.filtered_count).to be > 0
  end

  it "stops counting a trace as dropped once the filters keep it" do
    kept = RailsTracepointStack.capture { TraceSubject.new.nested(3) }

    RailsTracepointStack.configure { |config| config.file_path_to_filter_patterns = [] }
    dropped = RailsTracepointStack.capture { TraceSubject.new.nested(3) }

    expect(dropped.traces).to be_empty
    expect(dropped.filtered_count).to be > kept.filtered_count
  end

  it "explains an empty tree instead of just showing no calls" do
    session = RailsTracepointStack.capture { method_the_filters_drop }

    expect(session.to_tree).to include("no app code ran")
  end

  it "says how much was dropped, so the filters can be judged" do
    session = RailsTracepointStack.capture { method_the_filters_drop }

    expect(session.to_tree).to match(/\d+ traces from gems, the framework and Ruby/)
  end

  it "stays quiet when there is a tree to show" do
    session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

    expect(session.to_tree).not_to include("no app code ran")
  end

  it "reports the dropped count in the summary" do
    session = RailsTracepointStack.capture { method_the_filters_drop }

    expect(session.summary[:filtered]).to eq(session.filtered_count)
  end
end
