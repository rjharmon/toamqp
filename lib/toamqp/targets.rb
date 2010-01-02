

# All targets for a transport.
#
module TOAMQP::Target
  # Writes to an exchange.
  #
  class Generic  
    attr_reader :buffer, :headers
    
    # Initializes a target that publishes to a queue or to an exchange. 
    #
    def initialize(exchange, headers={})
      @exchange = exchange
      @buffer = String.new
      
      @headers  = stringify_keys headers
    end

    def write(buffer)
      @buffer << buffer
    end

    def flush
      require 'pp'
      pp [:flush, @buffer, headers]            

      @exchange.publish @buffer, 
        :headers => headers

      @buffer = ''
    end

    def stringify_keys(h)
      h.inject({}) { |h,(k,v)|
        h[k.to_s] = v.to_s
        h }
    end
  end
end