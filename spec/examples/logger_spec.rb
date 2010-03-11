require File.dirname(__FILE__) + '/../spec_helper'

describe Faqueue, "when running the logger example" do
  
  class MyLoggerRulez
    def initialize *args, &block
      opts = args.pop if args.last.is_a? Hash
      opts ||= {}

      printer(block) if block

      @prop = opts
      @tags = ([:timestamp] + args).uniq
    end

    attr_reader :prop
    alias :base :prop

    def log severity, *args
      opts = args.pop if args.last.is_a? Hash and args.size != 1
      opts ||= {}
      opts = @prop.clone.update(opts)

      data = args.shift

      data = {:type => :exception,
              :name => data.class.to_s.intern,
              :backtrace => data.backtrace,
              :message => data.message} if data.is_a? Exception

      (@tags + args).each do |tag|
        tag = tag.to_sym
        case tag
        when :timestamp
          opts.update :timestamp => Time.now
        when :hostname
          @hostname ||= { :hostname => `hostname`.strip }
          opts.update @hostname
        when :process
          @process_id ||= { :process_id => Process.pid,
                            :process_name => $0,
                            :process_parent_id => Process.ppid,
                            :thread_id => Thread.current.object_id }
          opts.update :process => @process_id
        else
          (opts[:tags] ||= []) << tag
        end
      end

      opts.update(:severity => severity,
                  :msg => data)

      print(opts)
      unless MyLoggerRulez.disabled?
        MQ.fanout('logging', :durable => true).publish Marshal.dump(opts)
      end

      opts
    end
    alias :method_missing :log

    def print data = nil, &block
      if block
        @printer = block
      elsif data.is_a? Proc
        @printer = data
      elsif data
        (pr = @printer || self.class.printer) and pr.call(data)
      else
        @printer
      end
    end
    alias :printer :print
    
    def self.printer &block
      @printer = block if block
      @printer
    end

    def self.disabled?
      !!@disabled
    end
    
    def self.enable
      @disabled = false
    end
    
    def self.disable
      @disabled = true
    end
  end
  
  
  before(:all) do
    overload_amqp
  end
  
  
  def run_client
    AMQP.start do
      log = MyLoggerRulez.new
      log.debug 'its working!'
    
      log = MyLoggerRulez.new do |msg|
        #require 'pp'
        #pp msg
        #puts
      end

      log.info '123'
      log.debug [1,2,3]
      log.debug :one => 1, :two => 2
      log.error Exception.new('123')

      log.info '123', :process_id => Process.pid
      log.info '123', :process
      log.debug 'login', :session => 'abc', :user => 123

      log = MyLoggerRulez.new(:webserver, :timestamp, :hostname, &log.printer)
      log.info 'Request for /', :GET, :session => 'abc'

      #AMQP.stop{ EM.stop }
    end
  end
  
  def run_server
    AMQP.start(:host => 'localhost') do
      
      @server_queue = MQ.queue('logger')
      @server_queue.bind(MQ.fanout('logging', :durable => true)).subscribe do |msg|
        msg = Marshal.load(msg)
      end
    end
  end
  
  it "should get the expected results" do
    EM.run do
      threads = []
      threads << Thread.new do
        run_server
      end
      threads << Thread.new do
        run_client
      end
      
      EM.add_timer(0.1) do
        @server_queue.should have(9).received_messages
        webserver_log = Marshal.load(@server_queue.received_messages.last)
        webserver_log[:tags].should == [:webserver, :GET]
        webserver_log[:msg].should == "Request for /"
        
        EM.stop
        threads.each { |t| t.join }
      end
      
    end
  end
  
end
