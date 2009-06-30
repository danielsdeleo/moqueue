require "eventmachine"

class MQ
  
  class << self
    def queue(name)
      Moqueue::MockQueue.new(name)
    end
    
    def fanout(name, opts={})
      Moqueue::MockExchange.new(opts.merge(:fanout=>name))
    end

  end
  
  def queue(name)
    Moqueue::MockQueue.new(name)
  end
  
  def topic(topic_name)
    Moqueue::MockExchange.new(:topic=>topic_name)
  end
  
end

module AMQP
  
  class << self
    attr_reader :closing
    alias :closing? :closing
  end
  
  def self.start(opts={},&block)
    EM.run(&block)
  end
  
  def self.stop
    @closing = true
    yield if block_given?
    @closing = false
  end
  
end
