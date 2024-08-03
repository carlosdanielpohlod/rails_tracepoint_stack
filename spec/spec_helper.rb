Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].sort.each { |file| require file }
Dir[File.join(File.dirname(__FILE__), './shared/**/*.rb')].each { |f| require f }

def initialize_gem_configuration!
  RailsTracepointStack.configuration = RailsTracepointStack::Configuration.new
end

RSpec.configure do |config|
  config.order = :random
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!

  config.around do |example|
    original_config = RailsTracepointStack.configuration.dup
    example.run
    RailsTracepointStack.configuration = original_config  
  end
end
