
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
    
    transport_config = {
      :source => TOAMQP::Source::Packet.new(packet)
    }
    
    # Has the client specified a reply_to queue?
    if reply_to= message[:header].headers[:reply_to]
      connection = TOAMQP.spawn_connection
      queue      = connection.queue(reply_to)
      
      transport_config.update(
        :destination => TOAMQP::Target::Generic.new(queue))
    end
    
    return TOAMQP::Transport.new(transport_config)
  end

  # Closes all connections
  #
  def close
    @topology.destroy
  end
end