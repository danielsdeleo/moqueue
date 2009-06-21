require "singleton"

module Moqueue
  class MockBroker
    include Singleton
    
    attr_reader :registered_queues
    
    def initialize
      reset!
    end
    
    def reset!
      @registered_queues = {}
      @registered_topic_exchanges = {}
    end
    
    def find_queue(name)
      @registered_queues[name]
    end
    
    def register_queue(queue)
      @registered_queues[queue.name] = queue
    end
    
    def register_topic_exchange(exchange)
      @registered_topic_exchanges[exchange.topic] = exchange
    end
    
    def find_topic_exchange(topic)
      @registered_topic_exchanges[topic]
    end
    
  end
end