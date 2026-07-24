module RailsTracepointStack
  # Turns raw stack positions into app-level nesting.
  #
  # Counting :call and :return events would not work here, for two reasons.
  # Most frames between two traced methods belong to gems and get filtered out,
  # so an event counter would indent app code by the depth of the framework
  # underneath it. And the tracer does not always watch :return at all - the
  # global tracer only subscribes to :call - so nothing would ever pop.
  #
  # Reading the real stack position of each kept trace avoids both. A frame
  # recorded at an equal or deeper position has necessarily finished, whether
  # it returned, raised, or was abandoned, so it gets dropped on the next
  # event rather than waiting for one that may never arrive.
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

    # A raise belongs to the innermost frame being tracked. It may report a
    # position deeper than that frame when the exception comes out of a C
    # method the app called, such as an arithmetic coercion, and there is no
    # tracked frame down there to attribute it to.
    def raised(raw_position)
      drop_finished_frames(raw_position, inclusive: false)

      [@stack.size - 1, 0].max
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
