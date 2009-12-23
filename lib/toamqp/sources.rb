
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
      
      @name  = "toamqp-private-#{TOAMQP.uuid_generator.generate}"
      @queue = connection.queue(@name, :auto_delete => true)
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
      @queue.subscribe(:message_max => 1, :ack => true) do |message|
        # Don't return from here, bug in bunny!
        # This will only work in some rubies!
      end
      
      @message = StringIO.new(message[:payload])
    end
    
  end
end