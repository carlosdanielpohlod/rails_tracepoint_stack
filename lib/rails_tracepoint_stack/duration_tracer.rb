require "rails_tracepoint_stack/tracer_base"
require "rails_tracepoint_stack/duration/tmp_save"

module RailsTracepointStack
  class DurationTracer < RailsTracepointStack::TracerBase

    private
    
    def generate_tracer
      @tracer ||= TracePoint.new(:line) do |tracepoint|
        trace = RailsTracepointStack::Trace.new(trace_point: tracepoint)
       
        next if ignore_trace?(trace: trace)

        current_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        
        if defined?(@last_time)
          RailsTracepointStack::TmpSave.save(trace: trace, current_time: current_time, last_time: @last_time)
        end

        @last_time = current_time
      end
    end
  end
end
