$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'rails_tracepoint_stack'

RSpec.configure do |config|
  config.order = :random
  config.filter_run_when_matching :focus
  config.raise_errors_for_deprecations!
end
