$rails_tracer_rtps = nil

module RailsTracepointStack
  class <<
    
end

if ENV.fetch('RAILS_TRACEPOINT_STACK', 'false') == 'true'
  $rails_tracer_rtps = RailsTracepointStack::Tracer.new.tracer
  $rails_tracer_rtps.enable

  at_exit do
    $rails_tracer_rtps.disable
  end
end
