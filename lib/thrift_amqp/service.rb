
require 'uuid'

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
  
  # Creates a new service based on the +connection+ given. If twoway is set
  # to true, construction will return objects that listen for replies and 
  # return demarshalled values. 
  #
  def initialize(connection, name, twoway=false)
    @connection = connection
    @name = name
    @exchange = _create_exchange(name)
    @twoway = twoway
  end
  
  # Creates and returns a client transport for the given service. Use this
  # transport for initializing your thrift stack. 
  #
  # Example: 
  #
  #   protocol = Thrift::BinaryProtocol.new(service.client_transport)
  #   client = AwesomeService::Client.new(protocol)
  #
  #   # prints 'chunky bacon!' on the server
  #   client.battleCry('chunky bacon!')   
  #
  def client_transport(filter={})
    Thrift::AMQP::Transport.new(exchange, nil, stringify(filter))
  end
  
  # Creates a service endpoint. This must be used to create a place for
  # messages to go, a queue in AMQP terms. Depending on wether you specify a
  # filter or not, a queue will be created that receives only some or all
  # messages. 
  #
  # Example: 
  #
  #   handler    = MyAwesomeHandler.new()
  #   processor  = AwesomeService::Processor.new(handler)
  #   transport  = service.endpoint.transport
  #
  #   server = Thrift::SimpleServer.new(processor, transport)
  #
  def endpoint(filter={})
    Thrift::AMQP::Endpoint.new(
      @connection,
      exchange, 
      @name, 
      stringify(filter))
  end
  
  # Creates a private endpoint for the service. The difference between a
  # private and a public endpoint is that the public endpoint has got a name
  # that is 'guessable', making it possible to connect to the same AMQP queue
  # from different server instances and handling work in a round robin
  # fashion. 
  #
  # If you don't want round robin, but rather broadcast-like behaviour, then 
  # use this method to create one queue per service endpoint. 
  #
  # Example: 
  #
  #   handler    = MyAwesomeHandler.new()
  #   processor  = AwesomeService::Processor.new(handler)
  #   transport  = service.private_endpoint.transport
  #
  #   server = Thrift::SimpleServer.new(processor, transport)
  #
  # This connects the server to something like SERVICE_NAME_PRIVATE_UUID. 
  #     
  def private_endpoint
    Thrift::AMQP::PrivateEndpoint.new(
      @connection, 
      exchange,
      @name)
  end
  
  def _create_exchange(name)
    @connection.exchange(name, 
      :type => :headers)
      
  rescue Bunny::ProtocolError
    raise "Could not create exchange #{name}, maybe it exists (with different params)?"
  end
  
  def stringify(hash)
    hash.inject({}) { |hash, (k,v)|
      hash[k.to_s] = v.to_s
      hash
    }
  end
end

class Thrift::AMQP::BaseEndpoint
  # The queue name that will be used for all transports generated using
  # this endpoint. 
  #
  attr_reader :queue_name

  def initialize(connection, exchange, exchange_name)
    @connection = connection
    @exchange = exchange
    @exchange_name = exchange_name
  end

  # Produces a transport for use with thrift. See Thrift::AMQP::Service for
  # documentation on #transport. 
  #
  def transport
    raise "Please initialize @queue in your subclass' constructor" unless defined?(@queue)
    
    Thrift::AMQP::ServerTransport.new(@exchange, @queue)
  end
end


# An AMQP endpoint maps to a server of a thrift service. The client makes 
# requests on the service and the server connects to a service endpoint.
#
class Thrift::AMQP::Endpoint < Thrift::AMQP::BaseEndpoint
  def initialize(connection, exchange, exchange_name, headers)
    super(connection, exchange, exchange_name)
    
    @queue = _create_queue(headers)
  end
  
  def _create_queue(filter)
    @queue_name = _public_endpoint_name(@exchange_name, filter)
    
    queue = @connection.queue(
      queue_name, 
      :auto_delete => true)

    if filter.empty?
      queue.bind(@exchange)
    else
      queue.bind(@exchange, 
        :arguments => filter.merge('x-match'=>'all'))
    end

    queue
  end
  
  def _public_endpoint_name(base_name, filter)
    [
      base_name,
      filter.to_a.sort.
        map { |(k,v)| "#{k}_#{v}" }
    ].flatten.join('_')
  end
end

# An AMQP endpoint maps to a server of a thrift service. The client makes 
# requests on the service and the server connects to a service endpoint.
#
# The private endpoint cannot be guessed by other processes and will be 
# unique to this process. This disables mechanisms like round-robin load 
# balancing, but allows you to receive answers for your requests privately 
# or have a message be distributed to all listeners (broadcast).
#
class Thrift::AMQP::PrivateEndpoint < Thrift::AMQP::BaseEndpoint
  def initialize(connection, exchange, exchange_name)
    super(connection, exchange, exchange_name)

    @uuid = UUID.new
    @queue = _create_queue
  end
  
  def _create_queue
    @queue_name = _private_endpoint_name(@exchange_name)
    
    queue = @connection.queue(
      queue_name, 
      :auto_delete => true)
      
    queue.bind(@exchange)
      
    queue
  end
  
  def _private_endpoint_name(base_name) 
    [
      base_name, 
      'private', 
      @uuid.generate].join('_')
  end
end