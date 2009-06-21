require File.dirname(__FILE__) + '/../spec_helper'

describe MockExchange do
  
  before(:each) do
    reset_broker
    @queue, @exchange = mock_queue_and_exchange
  end
  
  it "should manually attach queues" do
    ensure_deferred_block_called(:times => 2)
    exchange = mock_exchange
    one_queue, another_queue = mock_queue("one"), mock_queue("two")
    exchange.attach_queue(one_queue)
    exchange.attach_queue(another_queue)
    one_queue.subscribe do |msg|
      deferred_block_called && msg.should == "mmm, smoothies"
    end
    another_queue.subscribe do |msg|
      deferred_block_called && msg.should == "mmm, smoothies"
    end
    exchange.publish("mmm, smoothies")
  end
  
  it "should accept options for the publish method" do
    lambda {@exchange.publish("whateva eva", :key=>"foo.bar")}.should_not raise_error(ArgumentError)
  end
  
  it "should emulate topic exchanges" do
    #pending "support for storing and retrieving topic exchanges in MockBroker"
    topic_exchange = MockExchange.new(:topic => "lolcats")
    topic_exchange.topic.should == "lolcats"
  end
  
  it "should register new topic exchanges with the mock broker" do
    MockBroker.instance.expects(:register_topic_exchange)
    MockExchange.new(:topic => "lolz")
  end
  
  it "should return a previously created topic exchange when asked to create a new one with the same topic" do
    exchange = MockExchange.new(:topic => "fails")
    MockExchange.new(:topic => "fails").should equal exchange
  end
  
  it "should determine if routing keys match" do
    exchange = MockExchange.new(:topic => "lolz")
    key = MockExchange::BindingKey
    key.new("cats").matches?("cats").should be_true
    key.new("cats").matches?("cats").should be_true
    key.new("cats").matches?("dogs").should be_false
    key.new("cats.*").matches?("cats.fridge").should be_true
    key.new("cats.evil").matches?("cats.fridge").should be_false
    key.new("cats.*").matches?("cats.fridge.in_urs").should be_false
    key.new("cats.#").matches?("cats.fridge.in_urs").should be_true
  end
  
  it "should forward messages to a queue only if the keys match when emulating a topic exchange" do
    ensure_deferred_block_called
    exchange = MockExchange.new(:topic => "lolz")
    queue = MockQueue.new("lolz-lover")
    queue.bind(exchange, :key=>"cats.*").subscribe do |msg|
      msg.should == "ohai"
      deferred_block_called
    end
    exchange.publish("ohai", :key => "cats.attack")
  end
  
  it "should add the routing key to the headers' properties when publishing as a topic exchange" do
    ensure_deferred_block_called
    exchange = MockExchange.new(:topic => "mehDogs")
    queue = MockQueue.new("dogzLover").bind(exchange, :key=>"boxers.*")
    queue.subscribe do |headers, msg|
      deferred_block_called
      headers.routing_key.should == "boxers.awesome"
      msg.should == "Roxie"
    end
    exchange.publish("Roxie", :key=>"boxers.awesome")
  end
  
  it "should raise an error when publishing to a topic exchange without specifying a key" do
    exchange = MockExchange.new(:topic=>"failz")
    fail_msg = "you must provide a key when publishing to a topic exchange"
    lambda {exchange.publish("failtacular")}.should raise_error(ArgumentError, fail_msg)
  end
  
end