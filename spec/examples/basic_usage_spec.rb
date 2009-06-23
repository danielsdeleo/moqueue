require File.dirname(__FILE__) + '/../spec_helper'

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