
# Bridges thrift to AMQP. 
#
class TOAMQP::Bridge
  
  # Creates a bridge instance that will use the given +connection+ and send
  # outgoing messages to the service listening to +exchange_name+. 
  #
  def initialize(connection, exchange_name)
  end
  
  # Creates and returns a Thrift::BinaryProtocol instance that is connected
  # to the AMQP server. 
  #
  def protocol
    Thrift::BinaryProtocol.new(transport)
  end
  
  # Creates and returns a Thrift transport instance that will transport its
  # messages via AMQP to the exchange. 
  #
  def transport
    # client_source = Source::Queue.new(private_queue_name)
    # filtered_source = Source::BoundQueue.new(exchange_name, filter_queue_name(:filter => :yes))
    # broadcast_source = Source::BoundQueue.new(exchange_name, private_queue_name)
    # private_server_source = Source::Queue.new(private_queue_name)
    # 
    # client_dest = Target::Exchange.new(exchange_name)
    # client_dest2 = Target::Queue.new(private_queue_name)
    # 
    # server_dest = Target::Queue.new(reply_queue_name)
  end
end