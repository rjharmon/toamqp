
# An AMQP service maps to one thrift service definition. Calls on one thrift
# interface go to a service. From there they get routed to the service
# endpoints and dispatched to your code. 
#
# Example: 
#
#   # Will create a headers exchange with the name 'thrift_service'
#   thrift_service = connection.service('thrift_service')
#
#   # Now you can either create a queue for round robin delivery: 
#   round_robin_endpoint = thrift_service.endpoint
#
#   # Or you create a filtered round robin service: (only accepts requests
#   # that are made with the same filters)
#   round_robin_filtered = thrift_service.endpoint(:foo => :bar)
#
#   # Or you could create private endpoints that wont buffer up messages when
#   # no service is running: (multiple endpoints will ALL receive messages!) 
#   round_robin_transient = thrift_service.private_endpoint
#
# Alternatively, you could also create a service that permits answers (return
# values) to be passed back to the client: 
#
#   # Will create a headers exchange with the name 'thrift_service'
#   thrift_service = connection.service('thrift_service', :twoway => true)
# 
# NOTE: This is not currently implemented!
#
class Thrift::AMQP::Service
  
  # Exchange that the service uses for messaging.
  #
  attr_reader :exchange
  
  def initialize(connection, name)
    @connection = connection
    @name = name
    @exchange = _create_exchange(name)
  end
  
  # Creates and returns a client transport for the given service. Use this 
  # transport for initializing your thrift stack. 
  #
  # Example: 
  #
  #   protocol = Thrift::BinaryProtocol.new(service.transport)
  #   client = AwesomeService::Client.new(protocol)
  #
  #   client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server
  #
  def transport
    Thrift::AMQP::Transport.new(exchange)
  end
  
  def _create_exchange(name)
    @connection.exchange(name, 
      :type => :headers)
      
  rescue Bunny::ProtocolError
    raise "Could not create exchange #{name}, maybe it exists (with different params)?"
  end
end

# An AMQP endpoint maps to a server of a thrift service. The client makes 
# requests on the service and the server connects to a service endpoint.
#
class Thrift::AMQP::Endpoint
end