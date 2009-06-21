require File.dirname(__FILE__) + '/../spec_helper'

describe ObjectMethods do
  
  before(:each) do
    reset_broker
    @queue, @exchange = mock_queue_and_exchange
  end
  
  it "should reset the MockBroker" do
    MockBroker.instance.expects(:reset!)
    reset_broker
  end
  
  it "should name the queue ``anonymous'' if not given a name" do
    @queue.name.should == "anonymous"
  end
  
  it "should name the queue with the name given" do
    q, exchange = mock_queue_and_exchange("wassup")
    q.name.should == "wassup"
    q2 = mock_queue("watup")
    q2.name.should == "watup"
  end
  
  it "should create a matched mock queue and mock exchange" do
    ensure_deferred_block_called
    @queue.subscribe do |message|
      deferred_block_called
      message.should == "FTW"
    end
    @exchange.publish("FTW")
  end
  
  it "should allow for overloading AMQP and MQ" do
    overload_amqp
    defined?(AMQP).should be_true
    defined?(MQ).should be_true
  end
    
end