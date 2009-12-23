
# Server end of an AMQP transport.
#
class TOAMQP::ServerTransport
  # The queue this server serves.
  #
  attr_reader :topology

  def initialize(topology)
    @topology = topology
    @queue    = topology.queue
  end
  
  # Returns true if there are no messages left on the queue. Mostly used for
  # servers that run during tests.
  #
  def eof?
    @queue.message_count == 0
  end
  
  # Sets up connection for serving requests.
  #
  def listen
  end
  
  # Blocks until a request is made. Returns the transport that should be
  # used for communication with that client. 
  #
  def accept
    # Wait for a message to arrive
    message = nil
    @queue.subscribe(:message_max => 1, :ack => true) do |message|      
      # DON'T return from here, it will hit a bug in Bunny
      # This will only work in some rubies!
    end
    
    packet = message[:payload]
    
    return TOAMQP::Transport.new(
      :source => TOAMQP::Source::Packet.new(packet))
  end

  # Closes all connections
  #
  def close
    @topology.destroy
  end
end