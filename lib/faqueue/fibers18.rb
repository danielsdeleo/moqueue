# Courtesy Aman Gupta's (original) em-spec library
unless defined? Fiber
  require 'thread'

  class FiberError < StandardError; end

  class Fiber
    def initialize
      raise ArgumentError, 'new Fiber requires a block' unless block_given?

      @yield = Queue.new
      @resume = Queue.new

      @thread = Thread.new{ @yield.push [ *yield(*@resume.pop) ] }
      @thread.abort_on_exception = true
      @thread[:fiber] = self
    end
    attr_reader :thread
    
    def alive?
      @thread.alive?
    end
    
    def resume *args
      raise FiberError, 'dead fiber called' unless @thread.alive?
      raise FiberError, 'double resume' if @thread == Thread.current
      @resume.push(args)
      result = @yield.pop
      result.size > 1 ? result : result.first
    end
    
    def resume!
      @resume.push []
    end
    
    def yield *args
      @yield.push(args)
      result = @resume.pop
      result.size > 1 ? result : result.first
    end
    
    def self.yield *args
      raise FiberError, "can't yield from root fiber" unless fiber = Thread.current[:fiber]
      fiber.yield(*args)
    end

    def self.current
      Thread.current[:fiber] or raise FiberError, 'not inside a fiber'
    end

    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}>"
    end
  end
else
  require 'fiber' unless Fiber.respond_to?(:current)
end
