
# Server end of an AMQP transport.
#
class TOAMQP::ServerTransport
  # The queue this server serves.
  #
  attr_reader :queue

  def initialize(queue)
    @queue = queue
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
    queue.subscribe do |message|
      packet = message[:payload]

      return TOAMQP::Transport.new(
        :source => TOAMQP::Source::Packet.new(packet))
    end
  end

  # Closes all connections
  #
  def close
  end
end