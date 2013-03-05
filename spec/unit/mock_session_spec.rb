require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MockSession do
  it "should stub #on_tcp_connection_loss" do
    Moqueue::MockSession.new.on_tcp_connection_loss.should be_nil
  end
end