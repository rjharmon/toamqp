
class TOAMQP::Client
  # Creates a proxy class for a service that listens on the exchange given by
  # +exchange_name+. Specify the thrift module of your service using
  # +protocol_module+.
  #
  def self.new(exchange_name, protocol_module)
    connection = TOAMQP.spawn_connection
    
    client_class = protocol_module.const_get('Client')
    client_class.new(:protocol)
  end
end