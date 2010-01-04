
# All sources for a transport.
#
module TOAMQP::Source
  # Reading from a packet that has already arrived. 
  #
  class Packet
    def initialize(buffer)
      @io = StringIO.new(buffer)
    end
    
    def read(count)
      raise Thrift::TransportException if @io.eof?
      @io.read(count)
    end
  end
  
  # Creates and reads from a private, exclusive queue. 
  #
  class PrivateQueue
    attr_reader :queue
    
    def initialize(connection)
      @connection = connection
      
      @queue = connection.queue( 
        :exclusive => true,     # Only this process may consume the queue
        :auto_delete => true)   # Delete when the channel closes
      
      # Set up the binding to the responses exchange. Routing key must be
      # the broker generated name of our queue.
      exchange = connection.exchange('responses')
      @queue.bind(exchange, :key => @queue.name)
      
      @message = nil
    end
    
    def read(count)
      unless message_buffered?
        wait_for_message
      end
      
      @message.read(count)
    ensure
      @message = nil if @message && @message.eof?
    end
    
    def message_buffered?
      @message
    end
    
    def wait_for_message
      # TODO: This looks like we could introduce another layer just above
      # bunny... 23Dez09, ksc
      message = nil
      
      while not message_buffered?
        message = @queue.pop
        payload = message[:payload]
        
        @message = StringIO.new(payload) unless payload == :queue_empty
      end
    end
    
  end
end