require_relative "lib/rails_tracepoint_stack/version"

Gem::Specification.new do |s|
  s.name = "rails_tracepoint_stack"
  s.version = RailsTracepointStack::VERSION
  s.summary = "Runtime call tree for a Rails app: which methods ran, with what params, and what they returned."
  s.description = "Traces a block of your Rails app and returns the call tree of your own code - " \
    "arguments, return values, raised exceptions and call depth - with gems, the framework and " \
    "stdlib filtered out. Bounded output meant to be read directly, by a developer or by an AI " \
    "coding agent debugging the app."
  s.authors = ["Carlos Daniel Pohlod"]
  s.email = "carlospohlod@gmail.com"
  # Globbed rather than listed: the packaged agent skill is a .md file under
  # lib, and an omission there breaks the installer only at runtime. Globbed
  # from the gemspec's own directory, since the glob would otherwise follow
  # whatever directory `gem build` happened to be run from.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*.{rb,md}"] + ["README.md", "changelog.md"]
  end
  s.homepage = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.license = "MIT"
  s.metadata["documentation_uri"] = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/"
  s.metadata["changelog_uri"] = "https://github.com/carlosdanielpohlod/rails_tracepoint_stack/blob/main/changelog.md"

  s.required_ruby_version = ">= 3.0"
  s.add_development_dependency "rspec", "~> 3.0", ">= 3.0.0"
  s.add_development_dependency "rake", "~> 13.0", ">= 13.0.0"
  s.add_development_dependency "standard", "~> 1.39", ">= 1.39.1"
end
