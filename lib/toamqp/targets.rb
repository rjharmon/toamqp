

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
      
      @headers  = TOAMQP::Util.stringify_keys headers
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
  end
end