require File.dirname(__FILE__) + '/../spec_helper'

describe Matchers do
  class MatcherHarness
    include Moqueue::Matchers
  end
  
  before(:each) do
    @matchable = MatcherHarness.new
    @mock_moqueue = mock("mock Moqueue::MockQueue")
    @failure_exception = Spec::Expectations::ExpectationNotMetError
  end
  
  it "should include matchers in describe blocks automatically when using rspec" do
    self.class.include?(Moqueue::Matchers).should be_true
  end
  
  it "should implement Object#should have_received_message" do
    @mock_moqueue.expects(:received_message?).with("matchtacular").returns(true)
    @mock_moqueue.should have_received_message("matchtacular")
  end
  
  it "should implement Object#should_not have_received_message" do
    @mock_moqueue.expects(:received_message?).with("no match").returns(false)
    @mock_moqueue.should_not have_received_message("no match")
  end
  
  it "should have a useful failure message" do
    @mock_moqueue.expects(:received_message?).with("this fails").returns(false)
    failing_example = lambda {@mock_moqueue.should have_received_message("this fails")}
    error_message = "expected #{@mock_moqueue.inspect} to have received message ``this fails''"
    failing_example.should raise_error(@failure_exception, error_message)
  end
  
  it "should have a useful negative failure message" do
    @mock_moqueue.expects(:received_message?).with("FAIL").returns(true)
    failing_example = lambda{@mock_moqueue.should_not have_received_message("FAIL")}
    error_message = "expected #{@mock_moqueue.inspect} to not have received message ``FAIL''"
    failing_example.should raise_error(@failure_exception, error_message)
  end
  
  it "should fail gracefully if object being tested for #have_received doesn't respond to #received_message?" do
    begin
      Object.new.should have_received_message("foo")
    rescue => e
    end
    e.should be_a(NoMethodError)
    e.message.should match(/you can't use \`\`should have_received_message\'\' on #\<Object/)
  end
  
  it "should alias #have_received_message as #have_received for less verbosity" do
    @matchable.should respond_to(:have_received)
  end
  
  it "should alias #have_received_ack_for as #have_ack_for for less verbosity" do
    @matchable.should respond_to(:have_ack_for)
  end
  
  it "should implement Object#should have_received_ack_for(msg_text)" do
    @mock_moqueue.expects(:received_ack_for_message?).with("foo bar").returns(true)
    @mock_moqueue.should have_received_ack_for("foo bar")
  end
  
  it "should implement Object#should_not have_received_ack_for(msg_text)" do
    @mock_moqueue.expects(:received_ack_for_message?).with("bar baz").returns(false)
    @mock_moqueue.should_not have_received_ack_for("bar baz")
  end
  
  it "should have a helpful failure message" do
    @mock_moqueue.expects(:received_ack_for_message?).with("foo baz").returns(false)
    failure = lambda {@mock_moqueue.should have_received_ack_for("foo baz")}
    fail_msg = "expected #{@mock_moqueue.inspect} to have received an ack for the message ``foo baz''"
    failure.should raise_error(@failure_exception, fail_msg)
  end
  
  it "should have a helpful negative failure message" do
    @mock_moqueue.expects(:received_ack_for_message?).with("bar foo").returns(true)
    failure = lambda {@mock_moqueue.should_not have_received_ack_for("bar foo")}
    fail_msg = "expected #{@mock_moqueue.inspect} to not have received an ack for the message ``bar foo''"
    failure.should raise_error(@failure_exception, fail_msg)
  end
  
  it "should fail gracefully if object being tested for #have_received_ack_for doesn't respond to #received_ack_for_message?" do
    begin
      Object.new.should have_received_message("foo")
    rescue => e
    end
    e.should be_a(NoMethodError)
    e.message.should match(/you can't use \`\`should have_received_message\'\' on #\<Object/)
  end
  
end