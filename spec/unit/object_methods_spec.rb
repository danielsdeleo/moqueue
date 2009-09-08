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
  
  it "should name the queue ``anonymous-RANDOM_GARBAGE'' if not given a name" do
    @queue.name.should match(/anonymous\-[0-9a-f]{0,8}/)
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
  
  it "should provide a convenience method for creating mock queues" do
    mock_queue("Sugary").should be_kind_of(Moqueue::MockQueue)
  end
  
  it "should provide a convenience method for creating mock exchanges" do
    mock_exchange(:topic => "sweetSugar").should be_kind_of(Moqueue::MockExchange)
  end
  
end