require 'rails_tracepoint_stack/configuration'
require 'rails_tracepoint_stack/log_formatter'
require 'rails_tracepoint_stack/tracer'
require 'rails_tracepoint_stack/duration_tracer'

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

if ENV.fetch("ENABLE_EXECUTION_DURATION", "false") == "true"
  begin
    $rails_duration_tracer = RailsTracepointStack::DurationTracer.new

    $rails_duration_tracer.enable

    at_exit do
      $rails_duration_tracer.disable

      RailsTracepointStack::DurationTracerLogger.new.show_top_files
    end

  ensure
    #destroy the tmp file
  end
end
