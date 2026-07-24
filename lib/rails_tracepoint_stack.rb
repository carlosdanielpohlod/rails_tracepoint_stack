require 'rails_tracepoint_stack/configuration'
require 'rails_tracepoint_stack/log_formatter'
require 'rails_tracepoint_stack/tracer'
require 'rails_tracepoint_stack/limits'
require 'rails_tracepoint_stack/sink/collector'
require 'rails_tracepoint_stack/trace_session'

$rails_tracer_rtps = nil

module RailsTracepointStack
  class << self
    attr_writer :configuration, :logger

    def configuration
      @configuration ||= RailsTracepointStack::Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  CAPTURE_EVENTS = [:call, :return, :raise].freeze

  # Traces a block and hands back everything that happened inside it, instead
  # of writing to a log. Meant to be run as a one-off: capture, read, done.
  def self.capture(threads: :current, **limit_options)
    raise ArgumentError, "Block not given to #capture" unless block_given?

    collector = RailsTracepointStack::Sink::Collector.new(
      limits: RailsTracepointStack::Limits.new(**limit_options)
    )
    session = collector.session
    tracer = RailsTracepointStack::Tracer.new(
      sink: collector,
      events: CAPTURE_EVENTS,
      thread: (threads == :all) ? nil : Thread.current
    )

    tracer.enable
    begin
      session.result = yield(session)
    rescue Exception => error
      session.error = error
      raise
    ensure
      tracer.disable
    end

    session
  end

  def self.enable_trace
    raise ArgumentError, "Block not given to #enable_trace" unless block_given?

    tracer = RailsTracepointStack::Tracer.new
    tracer.enable
    yield
  ensure
    tracer.disable
  end
end

if ENV.fetch("RAILS_TRACEPOINT_STACK_ENABLED", "false") == "true"
  $rails_tracer_rtps = RailsTracepointStack::Tracer.new
  $rails_tracer_rtps.enable

  at_exit do
    $rails_tracer_rtps.disable
  end
end
