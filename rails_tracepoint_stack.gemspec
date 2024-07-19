require_relative "lib/rails_tracepoint_stack/version"

Gem::Specification.new do |s|
  s.name        = "rails_tracepoint_stack"
  s.version     = RailsTracepointStack::VERSION
  s.summary     = "Get a complete stack trace for your code on a Rails application."
  s.description = "A formatted output of all methods called in your rails application of code created by the developer, with the complete path to the class/module, including passed params."
  s.authors     = ["Carlos Daniel Pohlod"]
  s.email       = "carlospohlod@gmail.com"
  s.files       = [
    "lib/rails_tracepoint_stack.rb",
    "lib/rails_tracepoint_stack/configuration.rb",
    "lib/rails_tracepoint_stack/logger.rb",
    "lib/rails_tracepoint_stack/trace_filter.rb",
    "lib/rails_tracepoint_stack/tracer.rb",
    "lib/rails_tracepoint_stack/version.rb"
  ]
  s.homepage    = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.license     = "MIT"
  s.metadata["documentation_uri"] = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.metadata["changelog_uri"] = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/blob/main/changelog.md"

  s.required_ruby_version = '>= 3.0'
  s.add_development_dependency 'rspec', '~> 3.0', '>= 3.0.0'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.0'
end
