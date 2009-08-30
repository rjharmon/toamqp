
# Transport of thrift messages (oneway) using an AMQP backend. 
#
# Example: 
#
#   transport = Thrift::AMQP::Transport.connect('battle_cry')
#   protocol = Thrift::BinaryProtocol.new(transport)
#   client = AwesomeService::Client.new(protocol)
#   
#   client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server
#
class Thrift::AMQP::Transport < Thrift::BaseTransport
  POLL_SLEEP = 0.01
  
  # Connects the transport to the queue. Since client and server use much of
  # the same method to to this (and since queues/exchanges must be declared
  # with the same parameters), this is code shared between the server and 
  # the client.
  # 
  # Parameters: 
  # * +exchange_name+ - The name of the exchange to connect to. 
  # * +headers+ - The headers to look for (receive) or the headers to send. 
  #   Client and server should provide the same arguments. 
  #
  def self.connect(exchange_name, headers)
    connection = Bunny.new
    connection.start
    
    exchange = begin
      connection.exchange(exchange_name, 
        :type => :fanout)
    rescue Bunny::ProtocolError
      raise "Could not create exchange #{@exchange_name}, maybe it exists (with different params)?"
    end
    
    instance = new(connection, exchange)
    instance
  end
  
  # Constructs a transport based on an existing connection and a message
  # exchange (of the headers type). 
  #
  # It might be more simple to use the Transport.connect method.
  #
  def initialize(connection, exchange)
    @connection = connection
    @exchange = exchange
    
    @buffered_message = ''
    @write_buffer = ''
  end
  
  def read(sz)
    unless @queue
      @queue = @connection.queue(@exchange.name, 
        :auto_delete => true)
      
      @queue.bind(@exchange)
    end
    
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