

# All targets for a transport.
#
module TOAMQP::Target
  # Writes to an exchange.
  #
  class Exchange  
    def initialize(exchange)
      @exchange = exchange
      @buffer = String.new
    end

    def write(buffer)
      @buffer << buffer
    end

    def flush
      @exchange.publish @buffer
    end
  end
end