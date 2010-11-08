require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "AMQP", "when mocked out by Moqueue" do
  
  before(:each) do
    reset_broker
  end
  
  it "should have direct exchanges" do
    queue = mock_queue("direct-exchanges")
    queue.publish("you are correct, sir!")
    queue.subscribe { |message| "do something with message" }
    queue.received_message?("you are correct, sir!").should be_true
  end
  
  it "should have direct exchanges with acks" do
    queue = mock_queue("direct-with-acks")
    queue.publish("yessir!")
    queue.subscribe(:ack => true) { |headers, message| headers.ack  }
    queue.received_ack_for_message?("yessir!").should be_true
  end
  
  it "should have topic exchanges" do
    topic = mock_exchange(:topic => "TATFT")
    queue = mock_queue("rspec-fiend")
    queue.bind(topic, :key => "bdd.*").subscribe { |msg| "do something" }
    topic.publish("TATFT FTW", :key=> "bdd.4life")
    queue.received_message?("TATFT FTW").should be_true
  end
  
  it "should have topic exchanges with acks" do
    topic = mock_exchange(:topic => "animals")
    queue = mock_queue("cat-lover")
    queue.bind(topic, :key => "cats.#").subscribe(:ack => true) do |header, msg|
      header.ack
      "do something with message"
    end
    topic.publish("OMG kittehs!", :key => "cats.lolz.kittehs")
    topic.received_ack_for_message?("OMG kittehs!").should be_true
  end
  
  it "should have fanout exchanges with acks" do
    film = mock_exchange(:fanout => "Godfather")
    one_actor = mock_queue("Jack Woltz")
    other_actor = mock_queue("Captain McCluskey")
    one_actor.bind(film).subscribe(:ack =>true) { |h,msg| h.ack && "horse head" }
    other_actor.bind(film).subscribe(:ack => true) { |h,msg| h.ack && "dirty cops"  }
    offer = "you can't refuse"
    film.publish(offer)
    one_actor.received_message?(offer).should be_true
    other_actor.received_message?(offer).should be_true
    film.should have(2).acked_messages
  end
  
end

describe Moqueue, "with syntax sugar" do
  
  before(:each) do
    reset_broker
  end
  
  it "counts received messages" do
    queue = mock_queue
    queue.subscribe { |msg| msg.should_not be_nil }
    5.times {queue.publish("no moar beers kthxbye")}
    queue.should have(5).received_messages
  end
  
  it "counts acked messages" do
    queue = mock_queue
    queue.subscribe(:ack=>true) { |headers,msg| headers.ack }
    5.times { queue.publish("time becomes a loop") }
    queue.should have(5).acked_messages
  end
  
  it "makes the callback (#subscribe) block testable" do
    emphasis = mock_queue
    emphasis.subscribe { |msg| @emphasized = "**" + msg + "**" }
    emphasis.run_callback("show emphasis").should == "**show emphasis**"
  end
  
end

describe Moqueue, "when using custom rspec matchers" do
  
  it "should accept syntax like queue.should have_received('a message')" do
    queue = mock_queue("sugary")
    queue.subscribe { |msg| "eat the message" }
    queue.publish("a message")
    queue.should have_received("a message")
  end
  
  it "should accept syntax like queue_or_exchange.should have_ack_for('a message')" do
    queue = mock_queue("more sugar")
    queue.subscribe(:ack => true) { |headers, msg| headers.ack }
    queue.publish("another message")
    queue.should have_ack_for("another message")
  end
  
end