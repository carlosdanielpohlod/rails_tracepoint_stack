$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

RSpec.configure do |config|
  config.order = :random
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!
end
