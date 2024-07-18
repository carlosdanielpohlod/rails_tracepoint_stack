require 'rails_tracepoint_stack/configuration'

$rails_tracer_rtps = nil

module RailsTracepointStack
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= RailsTracepointStack::Configuration.new
    yield(configuration)
  end
end

if ENV.fetch('RAILS_TRACEPOINT_STACK', 'false') == 'true'
  $rails_tracer_rtps = RailsTracepointStack::Tracer.new.tracer
  $rails_tracer_rtps.enable

  at_exit do
    $rails_tracer_rtps.disable
  end
end
