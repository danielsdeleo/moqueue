require File.dirname(__FILE__) + '/../spec_helper'

describe MockHeaders do
  
  it "should respond to the same methods as real AMQP::Protocol::Header" do
    headers = Moqueue::MockHeaders.new
    headers.should respond_to(:size)
    headers.should respond_to(:weight)
    headers.should respond_to(:properties)
    headers.should respond_to(:to_frame)
  end
  
  it "should add properties given to constructor" do
    headers = MockHeaders.new({:routing_key=>"lolz.cats.inKitchen"})
  end
  
  it "should lookup unknown methods as keys in the hash" do
    headers = MockHeaders.new(:wtf_ftw_lolz_yo => "did I really write that?")
    headers.wtf_ftw_lolz_yo.should == "did I really write that?"
  end
  
end