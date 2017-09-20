require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MockQueue do

  before(:each) do
    reset_broker
    @queue, @exchange = mock_queue_and_exchange
  end

  it "should accept options for :ack=>(true|false) :nowait=>(true|false)" do
    lambda {@queue.subscribe(:ack=>true) { |message| p message}}.should_not raise_error(ArgumentError)
  end

  it "should pass mock headers to block when subscribe is given a block w/ 2 arity" do
    ensure_deferred_block_called
    @queue.subscribe do |headers, msg|
      headers.should be_kind_of(Moqueue::MockHeaders)
      msg.should == "the message"
      deferred_block_called
    end
    @exchange.publish("the message")
  end

  it "should allow retrieval of the headers for any published messages" do
    @queue.subscribe { |msg| msg }
    @exchange.publish("the message")
    @queue.received_headers.first.should be_kind_of(Moqueue::MockHeaders)
  end

  it "should create mock headers if pop is given a block w/ 2 arity" do
    pending
  end

  it "should process pending messages after a handler block is defined" do
    ensure_deferred_block_called
    @exchange.publish("found!")
    @queue.subscribe { |msg| deferred_block_called && msg.should == "found!" }
  end

  it "should not process pending messages twice" do
    ensure_deferred_block_called(:times=>2)
    @exchange.publish("take out the garbage")
    @queue.subscribe do |msg|
      deferred_block_called
      msg.should match(/take out (.*) garbage/)
    end
    @exchange.publish("take out more garbage")
  end

  it "should not ack messages when given or defaulting to :ack=>false" do
    ensure_deferred_block_called
    @queue.subscribe { |msg| deferred_block_called && msg.should == "hew-row" }
    @exchange.publish("hew-row")
    @exchange.received_ack_for_message?("hew-row").should_not be_true
  end

  it "should not ack messages when given :ack => true, but headers don't receive #ack" do
    ensure_deferred_block_called
    @queue.subscribe(:ack=>true) do |headers, msg|
      deferred_block_called
      msg.should == "10-4"
    end
    @exchange.publish("10-4")
    @exchange.received_ack_for_message?("10-4").should be_false
  end

  it "should ack messages when subscribe is given :ack=>true and headers are acked" do
    @queue.subscribe(:ack=>true) do |headers, msg|
      msg.should == "10-4"
      headers.ack
    end
    @exchange.publish("10-4")
    @exchange.received_ack_for_message?("10-4").should be_true
  end

  it "should provide ability to check for acks when direct exchange is used" do
    queue = MockQueue.new("direct-ack-check")
    queue.subscribe(:ack => true) do |headers, msg|
      msg.should == "ack me"
      headers.ack
    end
    queue.publish("ack me")
    queue.received_ack_for_message?("ack me").should be_true
  end

  it "should store received messages in the queues" do
    @queue.subscribe { |msg| msg.should == "save me!" }
    @exchange.publish("save me!")
    @queue.received_message?("save me!").should be_true
  end

  it "should #unsubscribe" do
    pending("should really remove the association with exchange")
    @queue.should respond_to(:unsubscribe)
  end

  it "should prevent double subscribe errors if unsubscribe is called inbetween" do
    @queue.subscribe { |msg| "once" }
    @queue.unsubscribe
    @queue.subscribe { |msg| "second" }.should_not raise_error(DoubleSubscribeError)
  end
  

  it "should ignore #prefetch but at least raise an error" do
    lambda { @queue.prefetch(1337) }.should_not raise_error
  end

  it "should raise an error on double subscribe" do
    @queue.subscribe { |msg| "once" }
    second_subscribe = lambda { @queue.subscribe {|msg| "twice"} }
    second_subscribe.should raise_error(DoubleSubscribeError)
  end

  it "should emulate direct exchange publishing" do
    ensure_deferred_block_called
    @queue.subscribe { |msg|deferred_block_called && msg.should == "Dyrekt" }
    @queue.publish("Dyrekt")
  end

  it "should take an optional name argument" do
    lambda { MockQueue.new("say-my-name") }.should_not raise_error
  end

  it "should register itself with the mock broker if given a name" do
    MockBroker.instance.expects(:register_queue)
    queue = MockQueue.new("with-a-name")
  end

  it "should return the previously created queue when trying to create a queue with the same name" do
    queue = MockQueue.new("firsties")
    MockQueue.new("firsties").should equal(queue)
  end

  it "should support binding to a topic exchange" do
    queue = MockQueue.new("lolz lover")
    topic_exchange = MockExchange.new(:topic => "lolcats")
    topic_exchange.expects(:attach_queue).with(queue, :key=>"lolcats.fridges")
    queue.bind(topic_exchange, :key => "lolcats.fridges") #http://lolcatz.net/784/im-in-ur-fridge-eatin-ur-foodz/
  end

  it "should make the callback (#subscribe block) available for direct use" do
    queue = MockQueue.new("inspect my guts, plz")
    queue.subscribe { |msg| msg + "yo" }
    queue.run_callback("hey-").should == "hey-yo"
  end

  it "should bind to a fanout exchange" do
    queue = MockQueue.new("fanouts are cool, too")
    lambda {queue.bind(MockExchange.new)}.should_not raise_error
  end

  it "should bind to a fanout exchange only once" do
    queue = MockQueue.new("fanouts are cool, too")
    exchange = MockExchange.new(:fanout => 'fanouts')
    queue.bind exchange
    queue.bind exchange # should be silently ignored
    exchange.publish "only get this once", {}
  end

  it "should provide a null subscribe that does nothing but allows messages to be received" do
    queue = MockQueue.new("nilly").null_subscribe
    queue.publish("I'm feelin this")
    queue.received_message?("I'm feelin this").should be_true
  end

end
