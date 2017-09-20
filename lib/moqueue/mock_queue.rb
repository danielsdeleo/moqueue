module Moqueue
  
  class DoubleSubscribeError < StandardError
  end
  
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
      if @subscribe_block 
        raise DoubleSubscribeError, "you can't subscribe to the same queue twice"
      end
      @subscribe_block = block
      @ack_msgs = opts[:ack] || false
      process_unhandled_messages
    end
    
    def receive(message, header_opts={})
      if callback = message_handler_callback
        headers = MockHeaders.new(header_opts)
        callback.call(*(callback.arity == 1 ? [message] : [headers, message]))
        received_messages_and_headers << {:message => message, :headers => headers}
      else
        receive_message_later(message, header_opts)
      end
    end
    
    def received_message?(message_content)
      received_messages.include?(message_content)
    end
    
    def received_routing_key?(key)
      received_messages_and_headers.find { |r| r[:headers] && r[:headers].properties[:routing_key] == key }
    end
    
    def unsubscribe
      @subscribe_block = nil
    end

    def prefetch(size)
      # noop
    end    
    
    def received_ack_for_message?(message_content)
      acked_messages.include?(message_content)
    end
    
    def publish(message, opts = {})
      if message_handler_callback
        receive(message)
      else
        deferred_publishing_fibers << Fiber.new do
          receive(message)
        end
      end
    end
    
    def bind(exchange, key=nil)
      exchange.attach_queue(self, key)
      self
    end

    def received_messages_and_headers
      @received_messages_and_headers ||= []
    end
    
    def received_messages
      received_messages_and_headers.map{|r| r[:message] }
    end
    
    def received_headers
      received_messages_and_headers.map{ |r| r[:headers] }
    end
    
    def acked_messages
      received_messages_and_headers.map do |r|
        r[:message] if @ack_msgs && r[:headers].received_ack?
      end
    end
    
    def run_callback(*args)
      callback = message_handler_callback
      callback.call(*(callback.arity == 1 ? [args.first] : args))
    end
    
    def callback_defined?
      !!message_handler_callback
    end
    
    # configures a do-nothing subscribe block to force
    # received messages to be processed and stored in
    # #received_messages
    def null_subscribe
      subscribe {|msg| nil}
      self
    end
    
    private
    
    def receive_message_later(message, header_opts)
      deferred_publishing_fibers << Fiber.new do
        self.receive(message, header_opts)
      end
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
    
  end
  
end
