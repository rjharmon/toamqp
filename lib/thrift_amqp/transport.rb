
# Transport of thrift messages (oneway) using an AMQP backend. 
#
class Thrift::AMQP::Transport < Thrift::BaseTransport
  POLL_SLEEP = 0.01
    
  # Constructs a transport based on an existing connection and a message
  # exchange (of the headers type). 
  #
  def initialize(exchange, queue)
    @exchange   = exchange
    @queue      = queue
    
    @buffered_message = ''
    @write_buffer = ''
  end
  
  def read(sz)
    # loop and pop until we have something to show 
    loop do
      if buffered_message?
        return buffered_message.slice!(0,sz) || ''
      end
      
      self.buffered_message = @queue.pop
      sleep POLL_SLEEP unless buffered_message?
    end
  end
  
  def write(buffer)
    write_buffer << buffer
  end
  def flush
    @exchange.publish(write_buffer)
    self.write_buffer = ''
  end
  
private
  attr_accessor :buffered_message
  attr_accessor :write_buffer
  
  def buffered_message?
    not (
      buffered_message == :queue_empty ||
      buffered_message.nil? ||
      buffered_message.empty?
    )
  end
end