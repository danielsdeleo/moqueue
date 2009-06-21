require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/example_helper'

describe Moqueue, "when running the stocks example" do
  include ExampleHelper
  
  def run_stocks
    AMQP.start(:host => 'localhost') do

      def log *args
        p [ Time.now, *args ]
      end

      def publish_stock_prices
        mq = MQ.new
        EM.add_periodic_timer(1){
          #puts

          {:appl => 170+rand(1000)/100.0, :msft => 22+rand(500)/100.0}.each do |stock, price|
            stock = "usd.#{stock}"

            log :publishing, stock, price
            mq.topic('stocks').publish(price, :key => stock)
          end
        }
      end

      def watch_appl_stock
        mq = MQ.new
        mq.queue('apple stock').bind(mq.topic('stocks'), :key => 'usd.appl').subscribe{ |price|
          log 'apple stock', price
        }
      end

      def watch_us_stocks
        mq = MQ.new
        mq.queue('us stocks').bind(mq.topic('stocks'), :key => 'usd.*').subscribe{ |info, price|
          log 'us stock', info.routing_key, price
        }
      end

      publish_stock_prices
      watch_appl_stock
      watch_us_stocks

    end
  end
  
  before(:each) do
    overload_amqp
    reset_broker
  end
  
  it "should get the correct result without raising exceptions" do
    pending "convert logging method to #capture_output and use #counter to limit execution"
    Timeout::timeout(3) do
      run_stocks
    end
  end
  
end