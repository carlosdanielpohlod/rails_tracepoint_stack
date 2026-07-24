require "spec_helper"

RSpec.describe "RailsTracepointStack.capture" do
  before do
    RailsTracepointStack.configure do |config|
      config.file_path_to_filter_patterns = [%r{spec/support/trace_subject}]
    end
  end

  it "returns a session holding the traces" do
    session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

    expect(session.traces.map(&:method_name)).to include(:add)
  end

  it "exposes the value the block returned" do
    session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

    expect(session.result).to eq(3)
  end

  it "watches calls, returns and raises" do
    session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

    expect(session.traces.map(&:kind).uniq).to contain_exactly(:call, :return)
  end

  it "requires a block" do
    expect { RailsTracepointStack.capture }.to raise_error(ArgumentError)
  end

  context "when the block raises" do
    it "re-raises the error to the caller" do
      expect { RailsTracepointStack.capture { TraceSubject.new.boom } }
        .to raise_error(ArgumentError, "kaboom")
    end

    it "still records the traces up to the failure" do
      session = nil

      begin
        RailsTracepointStack.capture { |current|
          session = current
          TraceSubject.new.boom
        }
      rescue ArgumentError
        nil
      end

      expect(session.traces.map(&:kind)).to include(:raise)
    end

    it "records the error on the session" do
      session = nil

      begin
        RailsTracepointStack.capture { |current|
          session = current
          TraceSubject.new.boom
        }
      rescue ArgumentError
        nil
      end

      expect(session.error).to be_a(ArgumentError)
    end
  end

  it "stops tracing once the block is done" do
    session = RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }
    before_count = session.traces.size

    TraceSubject.new.add(3, 4)

    expect(session.traces.size).to eq(before_count)
  end

  it "leaves the configured logger alone" do
    allow(RailsTracepointStack::Logger).to receive(:log)

    RailsTracepointStack.capture { TraceSubject.new.add(1, 2) }

    expect(RailsTracepointStack::Logger).not_to have_received(:log)
  end
end
