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
    @broker.registered_queues.size.should == 0
  end
  
  it "should keep a list of direct exchanges" do
    exchange = MockExchange.new(:direct => "thundercats")
    @broker.register_direct_exchange(exchange)
    @broker.find_direct_exchange("thundercats").should equal(exchange)
  end
  
  it "should keep a list of topic exchanges" do
    exchange = MockExchange.new(:topic => "lolcats")
    @broker.register_topic_exchange(exchange)
    @broker.find_topic_exchange("lolcats").should equal(exchange)
  end
  
  it "should keep a list of fanout queues" do
    exchange = MockExchange.new(:fanout => "joinTheNaniteBorg")
    @broker.register_fanout_exchange(exchange)
    @broker.find_fanout_exchange("joinTheNaniteBorg").should equal(exchange)
  end
  
end