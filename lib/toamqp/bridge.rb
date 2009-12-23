
require 'toamqp/transport'

# Bridges thrift to AMQP. 
#
class TOAMQP::Bridge
  attr_reader :connection, :exchange_name
  
  # Creates a bridge instance that will use the given +connection+ and send
  # outgoing messages to the service listening to +exchange_name+. 
  #
  def initialize(connection, exchange_name)
    @connection = connection
    @exchange_name = exchange_name
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
    TOAMQP::Transport.new(
      :source      => source,
      :destination => destination)
  end
  
  def source
    TOAMQP::Source::PrivateQueue.new(connection)
  end
  
  def destination
    exchange = connection.exchange(exchange_name)
    TOAMQP::Target::Exchange.new(exchange)
  end
end