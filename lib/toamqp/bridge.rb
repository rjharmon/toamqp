
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
    :bridge_generated_protocol
  end
end