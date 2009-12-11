
# Transport of thrift messages (oneway) using an AMQP backend. 
#
class Thrift::AMQP::Transport < Thrift::BaseTransport
  POLL_SLEEP = 0.01
  
  # Headers that are used for posting messages to the queue. See also the 
  # constructor argument with the same name.
  #
  attr_reader :headers
  
  # Exchange that is used for posting the messages (in oneway mode).
  #
  attr_reader :exchange
    
  # Constructs a transport based on an existing connection and a message
  # exchange (of the headers type). 
  #
  def initialize(connection, exchange, queue=nil, headers={})
    @connection = connection
    @exchange   = exchange
    @queue      = queue
    @headers    = headers
    
    @buffered_message = ''
    @write_buffer = ''
  end
  
  def read(sz)
    # loop and pop until we have something to show 
    loop do
      if buffered_message?
        log "Returning a chunk of #{sz} from queue #{@queue.name}"
        return buffered_message.slice!(0,sz) || ''
      end
      
      @last_network_message = @queue.pop
      self.buffered_message = @last_network_message[:payload]
      sleep POLL_SLEEP unless buffered_message?
    end
  end
  
  def write(buffer)
    write_buffer << buffer
  end
  def flush
    log "Flushing a buffer of length {#{write_buffer.size}}"
    
    message_headers = @headers.dup
    
    # If this node has a queue, we can receive answers:
    if @queue
      message_headers.merge!(
        'thrift_reply_to' => @queue.name)
    end
    
    if @exchange
      # To the server: publish to exchange
      @exchange.publish(write_buffer, :headers => message_headers)
    elsif @last_network_message
      # Back to the client - needs to connect to queue
      reply_to_queue_name = @last_network_message[:header].headers[:thrift_reply_to]
      queue = @connection.queue(reply_to_queue_name)
            
      queue.publish(write_buffer)
    end
    
    self.write_buffer = ''
  end
  
  def log(message)
    # puts "Ex: #{@exchange.name}" if @exchange
    # puts "Qu: #{@queue.name}" if @queue
    # # Comment this in to debug
    # puts message
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