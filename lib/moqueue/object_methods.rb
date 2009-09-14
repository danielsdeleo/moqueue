module Moqueue
  
  module ObjectMethods
    def mock_queue_and_exchange(name=nil)
      queue = mock_queue(name)
      exchange = mock_exchange
      exchange.attached_queues << queue
      [queue, exchange]
    end

    # Takes a string name as a parameter. Each queue name may only be used
    # once. Multiple calls to #mock_queue with the same +name+ will return 
    # the same object.
    def mock_queue(name=nil)
      MockQueue.new(name || "anonymous-#{rand(2**32).to_s(16)}")
    end
    
    # Takes a hash to specify the exchange type and its name.
    #
    #  topic = mock_exchange(:topic => 'topic exchange')
    def mock_exchange(opts={})
      MockExchange.new(opts)
    end
    
    # Overloads the class-level method calls typically used by AMQP code
    # such as MQ.direct, MQ.queue, MQ.topic, etc.
    def overload_amqp
      require MOQUEUE_ROOT + "moqueue/overloads"
    end
    
    # Deletes all exchanges and queues from the mock broker. As a consequence of
    # removing queues, all bindings and subscriptions are also deleted.
    def reset_broker
      MockBroker.instance.reset!
    end
    
  end
  
end

Object.send(:include, Moqueue::ObjectMethods)