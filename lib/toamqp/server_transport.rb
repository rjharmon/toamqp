
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
  
  # Blocks until a message is received from the queue server. 
  #
  def poll_for_message
    m = nil
    @queue.subscribe(:message_max => 1, :ack => true) do |message|      
      # DON'T return from here, it will hit a bug in Bunny. Subscription is 
      # not properly canceled on return, leaving our connection half good. (Ok, 
      # downright bad!)
      m = message
    end
    
    return m
  end
    
  # Blocks until a request is made. Returns the transport that should be
  # used for communication with that client. 
  #
  def accept
    # Wait for a message to arrive
    message = poll_for_message
    packet = message[:payload]
    
    transport_config = {
      :source => TOAMQP::Source::Packet.new(packet)
    }
    
    # Has the client specified a reply_to queue?
    if reply_to= message[:header].headers[:reply_to]
      # Opening a new connection since a threaded server will post messages
      # to the 'responses' exchange out of band with our communication with 
      # the broker.
      connection = TOAMQP.spawn_connection
      answer_exchange = connection.exchange('responses')

      target = TOAMQP::Target::Generic.new(
        answer_exchange, 
        :key => reply_to)
        
      transport_config.update(:destination => target)
    end
    
    return TOAMQP::Transport.new(transport_config)
  end

  # Closes all connections
  #
  def close
    @topology.destroy
  end
end