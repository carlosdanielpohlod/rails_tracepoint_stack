# rails_tracepoint_stack

**[carlosdanielpohlod.github.io/rails_tracepoint_stack](https://carlosdanielpohlod.github.io/rails_tracepoint_stack/)**

See what your Rails code actually did at runtime: which of *your* methods ran,
what arguments they got, what each one returned, and where an exception was
first raised — as a call tree, with gems, the framework and stdlib filtered out.

```ruby
session = RailsTracepointStack.capture(max_depth: 4) do
  Order.find(42).recalculate!
end

puts session.to_tree
```

```
Order#recalculate! (app/models/order.rb:88) {}
  Order#apply_discount (app/models/order.rb:102) {"total":200.0}
    Discount#rate_for (app/models/discount.rb:12) {"order":"#<Order id: 42>"}
      -> null
    -> 200.0
  -> 200.0
3 calls, 3 returns, 0 raises, 2 classes
```

`rate_for` returned nil. No `puts`, no log file, no restart.

A whole Rails request comes out about this long, because everything the
framework runs underneath is filtered away:

```
RealEstateAgenciesController#index (app/controllers/real_estate_agencies_controller.rb:14) {}
  IpLocation.guess_state_uf_and_city_name (app/services/ip_location.rb:15) {"ip":"127.0.0.1"}
    -> [null,null]
  -> null
render app/views/real_estate_agencies/index.html.erb {}
  -> "<!-- BEGIN app/views/real_estate_agencies/index.html.erb\n-->… (2507 chars)"
4 calls, 4 returns, 0 raises, 3 classes
```

That is 4 kept traces out of 13869 the tracer saw.

## Install

```ruby
# Gemfile
gem "rails_tracepoint_stack"
```

## Debugging with an AI agent

Agents reach for `puts` and log lines because they do not know this exists.
Install the packaged skill into your app and yours will use the gem instead:

```bash
bin/rails generate rails_tracepoint_stack:install
```

That writes `.claude/skills/debug-with-tracepoint/SKILL.md`, which tells the
agent when tracing beats reading code, how to keep the output inside its
context window, and how to read the tree. Pass `--force` to overwrite an
existing copy.

## Capturing

`capture` traces the block, returns a session and re-raises anything the block
raised. It watches only the calling thread, so it stays clean under Puma.

```ruby
session = RailsTracepointStack.capture { Order.find(42).recalculate! }

session.to_tree    # the indented call tree above
session.as_json    # the same data, structured, one entry per trace
session.summary    # {calls:, returns:, raises:, classes:, truncated:}
session.result     # what the block returned
session.error      # the exception that escaped, if any
session.traces     # the raw TraceRecord list
```

To keep the traces when the block blows up, take the session from the block
argument:

```ruby
session = nil
begin
  RailsTracepointStack.capture { |s| session = s; thing_that_blows_up }
rescue => error
  puts session.to_tree
end
```

### Keeping the output small

A real request produces tens of thousands of traces, so captures are bounded.

| Option | Default | What it does |
|---|---|---|
| `max_depth` | none | Drops traces nested deeper than this |
| `max_traces` | 5000 | Stops collecting; `session.truncated?` becomes true |
| `max_string_length` | 200 | Shortens long strings |
| `max_collection_size` | 20 | Shortens long arrays and hashes |
| `capture_params` | `true` | Set false to show only the flow |
| `capture_return` | `true` | Set false to show only the calls |
| `threads` | `:current` | `:all` also records background threads |

```ruby
RailsTracepointStack.capture(max_depth: 3, capture_return: false) { ... }
```

## Tracing the whole process

For code you cannot wrap in a block — boot, a rake task, a request handled by a
running server — enable the tracer globally instead. Output goes to
`log/rails_tracepoint_stack.log`.

```bash
RAILS_TRACEPOINT_STACK_ENABLED=true bin/rails server
```

```
called: Bar#perform in /path/to/app/services/bar.rb:12 with params: {}
```

`RailsTracepointStack.enable_trace { ... }` does the same for one block, also
writing to the log rather than returning a session.

## Configuration

```ruby
# config/initializers/rails_tracepoint_stack.rb

RailsTracepointStack.configure do |config|
  config.file_path_to_filter_patterns << %r{app/services/}
  config.ignore_patterns << %r{app/models/concerns/}
  config.log_format = :json
  config.log_external_sources = false
  config.logger = Rails.logger
end
```

| Configuration | Description |
|---|---|
| `file_path_to_filter_patterns` | Trace **only** files whose path matches one of these patterns |
| `ignore_patterns` | Skip traces whose file path matches one of these patterns |
| `log_format` | `:text` (default) or `:json`. Applies to the log, not to `capture` |
| `log_external_sources` | Include gems, bundler and stdlib. Default `false` |
| `logger` | Your own logger. Defaults to `log/rails_tracepoint_stack.log` |

A method missing from a trace is usually one the filters dropped as external —
add its path to `file_path_to_filter_patterns` to force it in.

## Worth knowing

- TracePoint makes the traced code noticeably slower — around 8x on a real
  Rails request. Fine for an investigation, not for something left running in
  production.
- Ruby >= 3.0.
- A `-> null` line directly under a `!!` line is the frame unwinding, not a
  method that returned nil.
- An empty tree says `no app code ran` along with how much was filtered. That
  usually means the block ran entirely inside gems — `Order.where(...).map(&:name)`
  calls no method you wrote, since `name` is generated by ActiveRecord.

## Links

- [Website](https://carlosdanielpohlod.github.io/rails_tracepoint_stack/) — the
  same story with real captured output, including a whole Rails request
- [RubyGems](https://rubygems.org/gems/rails_tracepoint_stack)
- [Changelog](changelog.md)

## License

MIT
