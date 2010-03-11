module Faqueue
  
  class MockExchange
    attr_reader :topic, :fanout, :direct
    
    class << self
      
      def new(opts={})
        if opts[:topic] && topic_exchange = MockBroker.instance.find_topic_exchange(opts[:topic])
          return topic_exchange
        end
        
        if opts[:fanout] && fanout = MockBroker.instance.find_fanout_exchange(opts[:fanout])
          return fanout
        end
        
        if opts[:direct] && direct = MockBroker.instance.find_direct_exchange(opts[:direct])
          return direct
        end
        
        super
      end
      
    end
    
    def initialize(opts={})
      if @topic = opts[:topic]
        MockBroker.instance.register_topic_exchange(self)
      elsif @fanout = opts[:fanout]
        MockBroker.instance.register_fanout_exchange(self)
      elsif @direct = opts[:direct]
        MockBroker.instance.register_direct_exchange(self)
      end
    end
    
    def attached_queues
      @attached_queues ||= []
    end
    
    def acked_messages
      attached_queues.map do |q|
        q = q.first if q.kind_of?(Array)
        q.acked_messages
      end.flatten
    end
    
    def attach_queue(queue, opts={})
      if topic
        attached_queues << [queue, TopicBindingKey.new(opts[:key])]
      elsif direct
        attached_queues << [queue, DirectBindingKey.new(opts[:key])]
      else
        attached_queues << queue
      end
    end
    
    def publish(message, opts={})
      require_routing_key(opts) if topic
      matching_queues(opts).each do |q| 
        q.receive(message, prepare_header_opts(opts))
      end
    end
    
    def received_ack_for_message?(message)
      acked_messages.include?(message)
    end
        
    private
    
    def routing_keys_match?(binding_key, message_key)
      if topic
        TopicBindingKey.new(binding_key).matches?(message_key)
      elsif direct
        DirectBindingKey.new(binding_key).matches?(message_key)
      end      
    end
    
    def matching_queues(opts={})
      return attached_queues unless topic || direct
      attached_queues.map {|q, binding| binding.matches?(opts[:key]) ? q : nil}.compact
    end
    
    def prepare_header_opts(opts={})
      header_opts = opts.dup
      if routing_key = header_opts.delete(:key)
        header_opts[:routing_key] = routing_key
      end
      header_opts
    end
    
    def require_routing_key(opts={})
      unless opts.has_key?(:key)
        raise ArgumentError, "you must provide a key when publishing to a topic exchange"
      end
    end
    
    public
    
    module BaseKey
      attr_reader :key

      def ==(other)
        other.respond_to?(:key) && other.key == @key
      end
    end

    class TopicBindingKey
      include BaseKey

      def initialize(key_string)
        @key = key_string.to_s.split(".")
      end

      def matches?(message_key)
        message_key, binding_key = message_key.split("."), key.dup

        match = true
        while match 
          binding_token, message_token = binding_key.shift, message_key.shift
          break if (binding_token.nil? && message_token.nil?) || (binding_token == "#")
          match = ((binding_token == message_token) || (binding_token == '*') || (message_token == '*'))
        end
        match
      end

    end
    
    # Requires an *exact* match
    class DirectBindingKey
      include BaseKey

      def initialize(key_string)
        @key = key_string.to_s
      end

      def matches?(message_key)
        message_key, binding_key = message_key.to_s, key.dup

        # looking for string equivalence
        message_key == binding_key
      end

    end
    
  end
  
end
