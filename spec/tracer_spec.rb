require 'spec_helper'
require 'rails_tracepoint_stack'
require 'rails_tracepoint_stack/tracer'
require 'ostruct'

class Foo
  def dummy_method
    return
  end
end

class IgnoredClass
  def ignored_method
    return
  end
end

RSpec.describe RailsTracepointStack::Tracer do
  before do
    RailsTracepointStack.configuration do |config|
      #TO DO: change it or both classes will be ignored
      config.ignore_patterns = ['spec/tracer_spec.rb']
    end
    @tracer = RailsTracepointStack::Tracer.new
  end

  it 'show methods outside the ignore patterns' do
    expect {
      @tracer.tracer.enable
        Foo.new.dummy_method
      @tracer.tracer.disable
    }.to output(/called: Foo#dummy_method/).to_stdout
  end

  it 'not show ignored classess' do
    expect {
      @tracer.tracer.enable

      IgnoredClass.new.ignored_method
      @tracer.tracer.disable
    }.not_to output(/called: IgnoredClass#ignored_method/).to_stdout
  end
end
