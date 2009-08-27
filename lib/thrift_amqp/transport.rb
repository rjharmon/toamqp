
class Thrift::AMQP::Transport < Thrift::BaseTransport
  POLL_SLEEP = 0.01
  
  # Connects the transport to the queue on the client side. 
  #
  def self.connect(exchange_name)
    connection = Bunny.new
    connection.start
    
    exchange = begin
      connection.exchange(exchange_name)
    rescue Bunny::ProtocolError
      raise "Could not create exchange #{@exchange_name}, maybe it exists (with different params)?"
    end
    
    instance = new(connection, exchange)
    instance
  end
  
  # Constructs a transport based on an existing connection and a message
  # exchange (of the headers type).
  #
  def initialize(connection, exchange)
    @connection = connection
    @exchange = exchange
    
    @buffered_message = ''
    @write_buffer = ''
  end
  
  def read(sz)
    unless @queue
      @queue = @connection.queue(@exchange.name)
      
      @queue.bind(@exchange)
    end
    
    # loop and pop until we have something to show 
    loop do
      if buffered_message?
        p [:read_returning, sz]
        return buffered_message.slice!(0,sz) || ''
      end
      
      p [:pop]
      self.buffered_message = @queue.pop
      p [:message, buffered_message]
      sleep POLL_SLEEP unless buffered_message?
    end
  end
  
  def write(buffer)
    p [:write, buffer]
    write_buffer << buffer
  end
  def flush
    p [:flush]
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