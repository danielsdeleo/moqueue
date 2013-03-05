require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/example_helper')

# NOTE: moqueue currently does not mimic AMQP's behavior of:
# 1) requiring graceful shutdown for acks to be delivered
# 2) returning messages to the queue if not acked
# 3) not processing messages when AMQP isn't "running"
#
# This causes the result of this test to differ from the actual result when run
# with a real broker. The true behavior should be that the 3rd message
# published should be unacknowledged and returned to the queue. In this test,
# all messages get acknowleged
describe Moqueue, "when running the ack example" do
  include ExampleHelper

  def run_ack_example(&perform_ack)
    AMQP.start(:host => 'localhost') do
      AMQP::Channel.queue('awesome').publish('Totally rad 1')
      AMQP::Channel.queue('awesome').publish('Totally rad 2')
      AMQP::Channel.queue('awesome').publish('Totally rad 3')

      i = 0

      # Stopping after the second item was acked will keep the 3rd item in the queue
      AMQP::Channel.queue('awesome').subscribe(:ack => true) do |h,m|
        if (i+=1) == 3
          #puts 'Shutting down...'
          AMQP.stop{ EM.stop }
        end

        if AMQP.closing?
          #puts "#{m} (ignored, redelivered later)"
        else
          #puts "received message: " + m
          perform_ack.call(h)
        end
      end
    end

  end

  before(:all) do
    overload_amqp
  end

  before(:each) do
    reset_broker
    reset!
  end

  it "should get the correct result without errors" do
    Timeout::timeout(2) do
      run_ack_example {|h| h.ack }
    end
    q = AMQP::Channel.queue('awesome')
    q.should have(3).acked_messages
    q.received_ack_for_message?('Totally rad 1').should be_true
    q.received_ack_for_message?('Totally rad 2').should be_true
    q.received_ack_for_message?('Totally rad 3').should be_true
  end

  it "should be able to ack in an EM.next_tick" do
    Timeout::timeout(2) do
      run_ack_example do |h|
        EM.next_tick { h.ack }
      end
    end
    q = AMQP::Channel.queue('awesome')
    q.should have(3).acked_messages
    q.received_ack_for_message?('Totally rad 1').should be_true
    q.received_ack_for_message?('Totally rad 2').should be_true
    q.received_ack_for_message?('Totally rad 3').should be_true
  end

  it "should be able to ack in an EM.defer callback" do
    Timeout::timeout(2) do
      run_ack_example do |h|
        EM.defer(proc {
            1337
          },
          proc { |result|
            result.should == 1337
            h.ack
          })
      end
    end
    q = AMQP::Channel.queue('awesome')
    q.should have(3).acked_messages
    q.received_ack_for_message?('Totally rad 1').should be_true
    q.received_ack_for_message?('Totally rad 2').should be_true
    q.received_ack_for_message?('Totally rad 3').should be_true
  end
end
