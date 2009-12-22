

# All targets for a transport.
#
module TOAMQP::Target
  # Writes to an exchange.
  #
  class Exchange  
    attr_reader :buffer
    
    def initialize(exchange)
      @exchange = exchange
      @buffer = String.new
    end

    def write(buffer)
      @buffer << buffer
    end

    def flush
      @exchange.publish @buffer

      @buffer = ''
      nil
    end
  end
end