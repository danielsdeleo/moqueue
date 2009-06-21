require File.dirname(__FILE__) + '/../spec_helper'

describe MockBroker do
  
  before(:each) do
    @broker = MockBroker.instance
    @broker.reset!
  end
  
  it "should keep a list of named queues" do
    queue = MockQueue.new("one-mocked-queue")
    @broker.register_queue(queue)
    @broker.find_queue("one-mocked-queue").should == queue
  end
  
  it "should reset itself" do
    @broker.register_queue(MockQueue.new("throwaway"))
    @broker.reset!
    @broker.registered_queues.count.should == 0
  end
  
  it "should keep a list of topic exchanges" do
    exchange = MockExchange.new(:topic => "lolcats")
    @broker.register_topic_exchange(exchange)
    @broker.find_topic_exchange("lolcats").should equal exchange
  end
  
end