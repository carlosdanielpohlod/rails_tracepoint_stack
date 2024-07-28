Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].sort.each { |file| require file }

def initialize_gem_configuration!
  RailsTracepointStack.configuration = RailsTracepointStack::Configuration.new
end

RSpec.configure do |config|
  config.order = :random
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!
end
