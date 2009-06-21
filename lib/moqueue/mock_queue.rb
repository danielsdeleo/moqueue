module Moqueue
  
  class MockQueue
    attr_reader :name
    
    class << self
      
      def new(name)
        if existing_queue = MockBroker.instance.find_queue(name)
          return existing_queue
        end
        super
      end
      
    end
    
    def initialize(name)
      @name = name
      MockBroker.instance.register_queue(self)
    end
    
    def subscribe(opts={}, &block)
      @subscribe_block = block
      @ack_msgs = opts[:ack] || false
      process_unhandled_messages
    end
    
    def receive(message, header_opts={})
      if callback = message_handler_callback
        headers = MockHeaders.new(header_opts)
        callback.call *(callback.arity == 1 ? [message] : [headers, message])
        received_messages << message
        @ack_msgs && headers.received_ack? ? message : nil
      else
        deferred_publishing_fibers << Fiber.new do
          self.receive(message)
        end
      end
    end
    
    def received_message?(message_content)
      received_messages.include?(message_content)
    end
    
    def unsubscribe
      true
    end
    
    def received_ack_for_message?(message_content)
      acked_messages.include?(message_content)
    end
    
    def publish(message)
      if message_handler_callback
        real_publish(message)
      else
        deferred_publishing_fibers << Fiber.new do
          real_publish(message)
        end
      end
    end
    
    def bind(topic, key)
      topic.attach_queue(self, key)
      self
    end
    
    private
    
    def received_messages
      @received_messages ||= []
    end
    
    def acked_messages
      @acked_messages ||= []
    end
    
    def deferred_publishing_fibers
      @deferred_publishing_fibers ||= []
    end
    
    def message_handler_callback
      @subscribe_block || @pop_block || false
    end
    
    def process_unhandled_messages
      while fiber = deferred_publishing_fibers.shift
        fiber.resume
      end
    end
    
    def real_publish(message)
      response = receive(message)
      acked_messages << response if response
    end
    
  end
  
end