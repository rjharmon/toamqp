
class TOAMQP::Transport
  attr_reader :destination
  
  # Initializes an AMQP transport. 
  #
  # Use the following options: 
  #
  #   :destination    where to send messages to, implements target
  #
  def initialize(options={})
    @destination = options[:destination]
  end

  # Writes a buffer to the destination
  #
  def write(buffer)
  end
  
  # Flushes destinations buffers (and will probably post to the queue, doing
  # something and getting an answer.)
  #
  def flush
  end
end