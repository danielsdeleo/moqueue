module Moqueue
  
  class MockHeaders
    attr_accessor :size, :weight
    
    def initialize(properties={})
      @properties = properties
    end
    
    def ack
      @received_ack = true
    end
    
    def received_ack?
      @received_ack || false
    end
        
    def properties
      @properties
    end
    
    def to_frame
      nil
    end
    
    def method_missing method, *args, &blk
      @properties.has_key?(method) ? @properties[method] : super
    end
  end
  
end