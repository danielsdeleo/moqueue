require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
    exchange.attached_queues.length.should == 2
    lambda { exchange.attach_queue(one_queue) }.should_not change(exchange.attached_queues, :length)
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

  it "should emulate direct exchanges" do
    direct_exchange = MockExchange.new(:direct => "thundercats")
    direct_exchange.direct.should == "thundercats"
  end

  it "should register new direct exchanges with the mock broker" do
    MockBroker.instance.expects(:register_direct_exchange)
    MockExchange.new(:direct => "lolz")
  end

  it "should return a previously created direct exchange when asked to create a new one with the same name" do
    exchange = MockExchange.new(:direct => "smoochie")
    MockExchange.new(:direct => "smoochie").should equal(exchange)
  end

  it "should determine if routing keys match exactly on the direct exchange" do
    exchange = MockExchange.new(:direct => "lolz")
    key = MockExchange::DirectBindingKey
    key.new("cats").matches?("cats").should be_true
    key.new("cats").matches?("dogs").should be_false
    key.new("cats.*").matches?("cats.fridge").should be_false
    key.new("cats.evil").matches?("cats.fridge").should be_false
    key.new("cats.*").matches?("cats.fridge.in_urs").should be_false
    key.new("cats.#").matches?("cats.fridge.in_urs").should be_false
  end

  it "should forward messages to a queue only if the keys match exactly when emulating a direct exchange" do
    ensure_deferred_block_called
    exchange = MockExchange.new(:direct => "thundercats")
    queue = MockQueue.new("ho")
    queue.bind(exchange, :key=>"cats").subscribe do |msg|
      msg.should == "ohai"
      deferred_block_called
    end
    exchange.publish("ohai", :key => "cats")
  end

  it "should NOT forward messages to a queue if the keys mismatch when emulating a direct exchange" do
    ensure_deferred_block_skipped
    exchange = MockExchange.new(:direct => "thundercats")
    queue = MockQueue.new("ho")
    queue.bind(exchange, :key=>"cats").subscribe do |msg|
      msg.should == "ohai"
      deferred_block_called # should never execute!
    end
    exchange.publish("ohai", :key => "cats.attack")
  end

  it "should add the routing key to the headers' properties when publishing as a direct exchange" do
    ensure_deferred_block_called
    exchange = MockExchange.new(:direct => "thunderdogs")
    queue = MockQueue.new("dogzh8er").bind(exchange, :key=>"boxers")
    queue.subscribe do |headers, msg|
      deferred_block_called
      headers.routing_key.should == "boxers"
      msg.should == "Roxie"
    end
    exchange.publish("Roxie", :key=>"boxers")
  end

  it "should NOT raise an error when publishing to a direct exchange without specifying a key" do
    exchange = MockExchange.new(:direct => "spike")
    fail_msg = "you must provide a key when publishing to a topic exchange"
    lambda {exchange.publish("failtacular")}.should_not raise_error(ArgumentError, fail_msg)
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
    MockExchange.new(:topic => "fails").should equal(exchange)
  end

  it "should determine if routing keys match" do
    exchange = MockExchange.new(:topic => "lolz")
    key = MockExchange::TopicBindingKey
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

  it "should allow the fanout exchange name to be queried" do
    exchange = MockExchange.new(:fanout => "hiMyNameIs")
    exchange.fanout.should == "hiMyNameIs"
  end

  it "should register new fanout exchanges with the MockBroker" do
    MockBroker.instance.expects(:register_fanout_exchange)
    MockExchange.new(:fanout => "nanite friendly")
  end

  it "should return the exact same fanout exchange if creating one with an identical name" do
    the_first_fanout = MockExchange.new(:fanout => "pseudo singleton")
    the_second_one = MockExchange.new(:fanout => "pseudo singleton")
    the_first_fanout.should equal(the_second_one)
  end

end