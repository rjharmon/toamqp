
# Server end of an AMQP transport.
#
class TOAMQP::ServerTransport
  
  # Sets up connection for serving requests.
  #
  def listen
  end
  
  # Blocks until a request is made. Returns the transport that should be
  # used for communication with that client. 
  #
  def accept
    packet = 'fixed'
    
    TOAMQP::Transport.new(
      :source => TOAMQP::Source::Packet.new(packet))
  end

  # Closes all connections
  #
  def close
  end
end