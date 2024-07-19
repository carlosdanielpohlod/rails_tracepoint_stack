require 'rails_tracepoint_stack/configuration'
require 'rails_tracepoint_stack/tracer'

$rails_tracer_rtps = nil

module RailsTracepointStack
  class << self
    attr_accessor :configuration, :logger
  end

  def self.configure
    self.configuration ||= RailsTracepointStack::Configuration.new
    yield(configuration)
  end

  def self.enable_trace
    raise ArgumentError, "Block not given to #enable_trace" unless block_given?

    tracer = RailsTracepointStack::Tracer.new.tracer
    tracer.enable
    yield
  ensure
    tracer.disable
  end
end

if ENV.fetch('RAILS_TRACEPOINT_STACK', 'false') == 'true'
  $rails_tracer_rtps = RailsTracepointStack::Tracer.new.tracer
  $rails_tracer_rtps.enable

  at_exit do
    $rails_tracer_rtps.disable
  end
end
