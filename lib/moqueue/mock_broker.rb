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
      @registered_direct_exchanges = {}
      @registered_topic_exchanges = {}
      @registered_fanout_exchanges = {}
    end

    def find_queue(name)
      @registered_queues[name]
    end

    def register_queue(queue)
      @registered_queues[queue.name] = queue
    end

    def register_direct_exchange(exchange)
      @registered_direct_exchanges[exchange.direct] = exchange
    end

    def find_direct_exchange(name)
      @registered_direct_exchanges[name]
    end

    def register_topic_exchange(exchange)
      @registered_topic_exchanges[exchange.topic] = exchange
    end

    def find_topic_exchange(topic)
      @registered_topic_exchanges[topic]
    end

    def register_fanout_exchange(exchange)
      @registered_fanout_exchanges[exchange.fanout] = exchange
    end

    def find_fanout_exchange(fanout_name)
      @registered_fanout_exchanges[fanout_name]
    end

  end
end