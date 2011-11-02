require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

  it "should create a stubbed Channel.new" do
    AMQP::Channel.new.should be_a(AMQP::Channel)
  end

  it "should emulate the behavior of Channel.new by yielding to a block" do
    message = "problem in block"
    begin
      AMQP::Channel.new { |channel| raise RuntimeError.new(message) }.should raise_error(RuntimeError.new(message))
    rescue RuntimeError => re
      re.message.should == message
    end
  end

  it "should provide a AMQP::Channel.queue class method" do
    AMQP::Channel.queue('FTW').should be_a(Moqueue::MockQueue)
  end

  it "should emulate the behavior of AMQP::Channel.closing?" do
    ensure_deferred_block_called
    AMQP.stop do
      deferred_block_called
      AMQP.should be_closing
    end
  end

  it "should create direct exchanges" do
    AMQP::Channel.new.direct("directamundo").should == MockExchange.new(:direct => "directamundo")
  end

  it "should create topic exchanges" do
    AMQP::Channel.new.topic("lolzFTW").should == MockExchange.new(:topic => "lolzFTW")
  end

  it "should create topic exchanges with options" do
    AMQP::Channel.new.topic("optsFTW", {}).should == MockExchange.new(:topic => "optsFTW")
  end

  it "should provide a AMQP::Channel.direct class method" do
    AMQP::Channel.direct("direct", :durable=>true).should be_a(Moqueue::MockExchange)
  end

  it "should provide a AMQP::Channel.fanout class method" do
    AMQP::Channel.fanout("fanout", :durable=>true).should be_a(Moqueue::MockExchange)
  end

  it "should create a named fanout queue via AMQP::Channel.fanout" do
    fanout = AMQP::Channel.fanout("SayMyNameSayMyName", :durable=>true)
    fanout.should be_a(Moqueue::MockExchange)
    fanout.fanout.should == "SayMyNameSayMyName"
  end

  it "should ignore #prefetch but at least raise an error" do
    lambda { AMQP::Channel.new.prefetch(1337) }.should_not raise_error
  end

  it "should stub .connection" do
    AMQP.connection.should be_a(Moqueue::MockSession)
  end
end
