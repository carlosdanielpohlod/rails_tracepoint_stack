require "spec_helper"

RSpec.describe "trace depth" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  def depths_of(session, kind)
    session.traces.select { |record| record.kind == kind }
      .map { |record| [record.method_name, record.depth] }
  end

  it "reports the outermost call at depth zero" do
    session = RailsTracepointStack.capture { TraceSubject.new.nested(3) }

    expect(depths_of(session, :call)).to include([:nested, 0])
  end

  it "reports a nested call one level deeper" do
    session = RailsTracepointStack.capture { TraceSubject.new.nested(3) }

    expect(depths_of(session, :call)).to include([:doubled, 1])
  end

  it "reports a return at the same depth as its call" do
    session = RailsTracepointStack.capture { TraceSubject.new.nested(3) }

    expect(depths_of(session, :return)).to include([:doubled, 1], [:nested, 0])
  end

  it "returns to depth zero for a sibling call" do
    session = RailsTracepointStack.capture do
      TraceSubject.new.nested(3)
      TraceSubject.new.add(1, 2)
    end

    expect(depths_of(session, :call)).to include([:add, 0])
  end

  it "reports the depth of the frame that raised" do
    session = RailsTracepointStack.capture do |_current|
      begin
        TraceSubject.new.nested_boom
      rescue ArgumentError
        nil
      end
    end

    expect(depths_of(session, :raise)).to eq([[:boom, 1]])
  end

  it "recovers the depth after an exception unwinds frames" do
    session = RailsTracepointStack.capture do
      begin
        TraceSubject.new.nested_boom
      rescue ArgumentError
        nil
      end
      TraceSubject.new.add(1, 2)
    end

    expect(depths_of(session, :call)).to include([:add, 0])
  end
end
