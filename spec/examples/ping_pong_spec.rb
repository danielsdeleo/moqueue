require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/example_helper'

describe Faqueue, "when testing the ping pong example" do
  include ExampleHelper
  
  def ping_pong
    AMQP.start(:host => 'localhost') do

      # AMQP.logging = true

      amq = MQ.new
      EM.add_periodic_timer(0.1){
        @counter_val = counter
        capture_output @counter_val, :sending, 'ping'
        amq.queue('one').publish('ping')
      }

      amq = MQ.new
      amq.queue('one').subscribe{ |msg|
        capture_output @counter_val, 'one', :received, msg, :sending, 'pong'
        amq.queue('two').publish('pong')
      }

      amq = MQ.new
      amq.queue('two').subscribe{ |msg|
        capture_output @counter_val, 'two', :received, msg
      }

    end
    
  end
  
  before(:all) do
    overload_amqp
  end
  
  before(:each) do
    reset!
  end
  
  it "should get the correct result without error" do
    Timeout::timeout(5) do
      ping_pong
    end
    expected = [[1, :sending, "ping"], [1, "one", :received, "ping", :sending, "pong"], [1, "two", :received, "pong"], 
                [2, :sending, "ping"], [2, "one", :received, "ping", :sending, "pong"], [2, "two", :received, "pong"]]
    @captured_output.should ==  expected
  end
end
