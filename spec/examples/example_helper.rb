module ExampleHelper
  def capture_output(*args)
    @captured_output << args
  end

  def counter
    @counter += 1
    EM.stop {AMQP.stop} if @counter >= 2
    @counter
  end

  def reset!
    @counter, @captured_output = 0, []
  end

end