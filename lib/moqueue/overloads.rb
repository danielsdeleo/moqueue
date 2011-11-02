require "eventmachine"


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

  def self.connect(*args)
  end

  def self.connection
    Moqueue::MockSession.new
  end

  class Channel
    class << self
      def queue(name)
        Moqueue::MockQueue.new(name)
      end

      def direct(name, opts={})
        Moqueue::MockExchange.new(opts.merge(:direct=>name))
      end

      def fanout(name, opts={})
        Moqueue::MockExchange.new(opts.merge(:fanout=>name))
      end
    end

    def initialize(*args, &block)
      yield self if block_given?
    end

    def direct(name, opts = {})
      Moqueue::MockExchange.new(opts.merge(:direct => name))
    end

    def fanout(name, opts = {})
      Moqueue::MockExchange.new(opts.merge(:fanout => name))
    end

    def queue(name, opts = {})
      Moqueue::MockQueue.new(name)
    end

    def topic(topic_name, opts = {})
      Moqueue::MockExchange.new(:topic=>topic_name)
    end

    def prefetch(size)
      # noop
    end

    def on_error(&block)
      # noop
    end
  end
end