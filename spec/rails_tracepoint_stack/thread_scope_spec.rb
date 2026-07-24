require "spec_helper"

RSpec.describe "capture thread scope" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  def methods_in(session)
    session.traces.map(&:method_name)
  end

  it "ignores work done on other threads" do
    session = RailsTracepointStack.capture do
      Thread.new { TraceSubject.new.add(1, 2) }.join
      TraceSubject.new.doubled(3)
    end

    expect(methods_in(session)).to include(:doubled)
    expect(methods_in(session)).not_to include(:add)
  end

  it "records other threads when asked to watch all of them" do
    session = RailsTracepointStack.capture(threads: :all) do
      Thread.new { TraceSubject.new.add(1, 2) }.join
    end

    expect(methods_in(session)).to include(:add)
  end

  it "keeps depth independent per thread" do
    session = RailsTracepointStack.capture(threads: :all) do
      Thread.new { TraceSubject.new.nested(3) }.join
    end

    depths = session.traces.select(&:call?).map { |record| [record.method_name, record.depth] }

    expect(depths).to include([:nested, 0], [:doubled, 1])
  end
end
