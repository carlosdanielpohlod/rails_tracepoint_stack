module RailsTracepointStack
  # Turns raw stack positions into app-level nesting.
  #
  # Counting :call and :return events would not work here. Most frames between
  # two traced methods belong to gems and get filtered out, so an event counter
  # would indent app code by the depth of the framework underneath it. It would
  # also drift permanently on any event the tracer does not see: tracing that
  # starts partway up a stack, or a frame left behind by a non-local exit.
  #
  # Reading the real stack position of each kept trace avoids both. A frame
  # recorded at an equal or deeper position has necessarily finished, however
  # it finished, so it gets dropped.
  class DepthTracker
    def initialize
      @stack = []
    end

    def enter(raw_position)
      drop_finished_frames(raw_position, inclusive: true)
      depth = @stack.size
      @stack.push(raw_position)
      depth
    end

    def leave(raw_position)
      drop_finished_frames(raw_position, inclusive: false)
      return @stack.size unless @stack.last == raw_position

      @stack.pop
      @stack.size
    end

    def raised(raw_position)
      drop_finished_frames(raw_position, inclusive: false)
      return @stack.size if @stack.last != raw_position

      @stack.size - 1
    end

    private

    def drop_finished_frames(raw_position, inclusive:)
      if inclusive
        @stack.pop while @stack.last && @stack.last >= raw_position
      else
        @stack.pop while @stack.last && @stack.last > raw_position
      end
    end
  end
end
