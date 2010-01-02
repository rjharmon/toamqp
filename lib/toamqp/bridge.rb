
require 'toamqp/transport'

# Bridges thrift to AMQP. 
#
class TOAMQP::Bridge
  attr_reader :connection, :exchange_name, :headers
  
  # Creates a bridge instance that will use the given +connection+ and send
  # outgoing messages to the service listening to +exchange_name+. 
  #
  def initialize(connection, exchange_name, headers)
    @connection = connection
    @exchange_name = exchange_name.to_s
    @headers = headers.dup
  end
  
  # Creates and returns a Thrift::BinaryProtocol instance that is connected
  # to the AMQP server. 
  #
  def protocol
    Thrift::BinaryProtocol.new(transport)
  end
  
  # Creates and returns a Thrift transport instance that will transport its
  # messages via AMQP to the exchange. The transport also creates an anonymous
  # return queue that will be used when bidirectional communication is
  # requested.
  #
  def transport
    reply_to = source()
    reply_to_queue = reply_to.queue.name
    
    TOAMQP::Transport.new(
      :source      => reply_to,
      :destination => destination(reply_to_queue))
  end
  
  def source
    TOAMQP::Source::PrivateQueue.new(connection)
  end
  
  def destination(reply_to_queue_name)
    exchange_type = headers.empty? ? :direct : :headers
    exchange = connection.exchange(exchange_name, :type => exchange_type)
    
    TOAMQP::Target::Generic.new(exchange, 
      headers.merge(:reply_to => reply_to_queue_name))
  end
end