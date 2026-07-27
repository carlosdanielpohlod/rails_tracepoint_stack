require 'rails_tracepoint_stack/configuration'
require 'rails_tracepoint_stack/log_formatter'
require 'rails_tracepoint_stack/tracer'
require 'rails_tracepoint_stack/limits'
require 'rails_tracepoint_stack/skill_installer'
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
  BLOCK_EVENTS = [:b_call, :b_return].freeze

  # Traces a block and hands back everything that happened inside it, instead
  # of writing to a log. Meant to be run as a one-off: capture, read, done.
  # Blocks are off by default: a block written inside a loop fires once per
  # element, so watching them costs more traces than watching methods does.
  # Turn them on to see scopes, lambdas and anything else whose logic lives in
  # a block rather than a method.
  def self.capture(threads: :current, blocks: false, **limit_options, &traced)
    raise ArgumentError, "Block not given to #capture" unless traced

    collector = RailsTracepointStack::Sink::Collector.new(
      limits: RailsTracepointStack::Limits.new(**limit_options)
    )
    session = collector.session
    tracer = RailsTracepointStack::Tracer.new(
      sink: collector,
      events: blocks ? CAPTURE_EVENTS + BLOCK_EVENTS : CAPTURE_EVENTS,
      thread: (threads == :all) ? nil : Thread.current,
      own_block: traced
    )

    tracer.enable
    begin
      session.result = traced.call(session)
    rescue Exception => error
      session.error = error
      raise
    ensure
      tracer.disable
      session.filtered_count = tracer.filtered_count
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
