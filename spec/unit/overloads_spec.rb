require File.dirname(__FILE__) + '/../spec_helper'

describe "AMQP and MQ", "when overloaded by moqueue/overloads" do
  
  before(:all) do
    overload_amqp
  end
  
  it "should make AMQP.start take options and a block without connecting to AMQP broker" do
    ensure_deferred_block_called
    AMQP.start(:host => "localhost") do
      deferred_block_called
      EM.stop
    end
  end
  
  it "should run EM in AMQP.start" do
    EM.expects(:run)
    AMQP.start { EM.stop }
  end
  
  it "should provide a MQ.queue class method" do
    MQ.queue('FTW').should be_a(Moqueue::MockQueue)
  end
  
  it "should emulate the behavior of MQ.closing?" do
    ensure_deferred_block_called
    AMQP.stop do 
      deferred_block_called
      AMQP.should be_closing
    end
  end
  
  it "should create direct exchanges" do
    MQ.new.direct("directamundo").should == MockExchange.new(:direct => "directamundo")
  end
  
  it "should create topic exchanges" do
    MQ.new.topic("lolzFTW").should == MockExchange.new(:topic => "lolzFTW")
  end
  
  it "should provide a MQ.direct class method" do
    MQ.direct("direct", :durable=>true).should be_a(Moqueue::MockExchange)
  end
  
  it "should provide a MQ.fanout class method" do
    MQ.fanout("fanout", :durable=>true).should be_a(Moqueue::MockExchange)
  end
  
  it "should create a named fanout queue via MQ.fanout" do
    fanout = MQ.fanout("SayMyNameSayMyName", :durable=>true)
    fanout.should be_a(Moqueue::MockExchange)
    fanout.fanout.should == "SayMyNameSayMyName"
  end
  
end