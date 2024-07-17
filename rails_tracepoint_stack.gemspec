Gem::Specification.new do |s|
  s.name        = "rails_tracepoint_stack"
  s.version     = RailsTracepointStack::VERSION
  s.summary     = "Get a complete stack trace for your code on a Rails application."
  s.description = "A formatted output of all methods called in your rails application of code created by the developer, with the complete path to the class/module, including passed params."
  s.authors     = ["Carlos Daniel Pohlod"]
  s.email       = "carlospohlod@gmail.com"
  s.files       = ["lib/rails_tracepoint_stack.rb", "lib/rails_tracepoint_stack/version.rb"]
  s.homepage    = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.license     = "MIT"
  s.metadata["documentation_uri"] = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.required_ruby_version = '>= 3.0'
end
