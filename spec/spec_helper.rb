require "rubygems"
require "spec"

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

require File.dirname(__FILE__) + "/../lib/moqueue"

# Make sure tests fail if deferred blocks (for susbscribe and pop) don't get called
def ensure_deferred_block_called(opts={:times=>1})
  @poke_me = mock("poke_me")
  @poke_me.expects(:deferred_block_called).times(opts[:times])
end

def deferred_block_called
  @poke_me.deferred_block_called
  true
end

def ensure_deferred_block_skipped
  @skip_me = mock("poke_me")
  @skip_me.expects(:deferred_block_called).times(0)
end

include Moqueue