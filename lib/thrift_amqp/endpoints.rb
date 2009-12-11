# An AMQP endpoint maps to a server of a thrift service. The client makes
# requests on the service and the server connects to a service endpoint.
#  
# This is the abstract superclass of all endpoints. Implementors should
# override #create_queue and #bind_queue
#
class Thrift::AMQP::BaseEndpoint
  # The queue name that will be used for all transports generated using
  # this endpoint. 
  #
  attr_reader :queue_name, :connection, :exchange

  def initialize(connection, exchange, exchange_name)
    @connection = connection
    @exchange = exchange
    @exchange_name = exchange_name
  end

  # Returns the endpoints queue. Note that this queue is initially unbound and
  # will not receive any messages. If you want to bind it to the exchange,
  # please call #bind_queue.
  #
  def queue
    @queue ||= create_queue
  end

  # Produces a transport for use with thrift. See Thrift::AMQP::Service for
  # documentation on #transport. 
  #
  def transport
    create_queue
    bind_queue
    
    Thrift::AMQP::ServerTransport.new(connection, exchange, queue)
  end
  
  # Override this to create the queue
  #
  def create_queue
    raise NotImplementedError, "Abstract superclass"
  end
  
  # Override this to bind the queue to the exchange (in the case of a server
  # transport).
  #
  def bind_queue
    raise NotImplementedError, "Abstract superclass"
  end
end

# An AMQP endpoint maps to a server of a thrift service. The client makes 
# requests on the service and the server connects to a service endpoint.
#
# Depending on the filter you set, this will create a queue with a constant
# public name that looks like this: 
#
#   service_name
#   service_name_foo_bar    # when given :foo => :bar as filter
#   service_name_foo_1      # when given :foo => 1 as filter
#
class Thrift::AMQP::Endpoint < Thrift::AMQP::BaseEndpoint
  attr_reader :headers
  
  def initialize(connection, exchange, exchange_name, headers)
    super(connection, exchange, exchange_name)
    
    @headers = headers
    @queue_name = _public_endpoint_name(@exchange_name, headers)
  end
    
  def bind_queue
    if headers.empty?
      queue.bind(exchange)
    else
      queue.bind(exchange, 
        :arguments => headers.merge('x-match'=>'all'))
    end
  end
  
  def create_queue
    queue = connection.queue(
      queue_name, 
      :auto_delete => true)

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
# unique to this process. Its queue name will look like this: 
#
#   service_name_private_UUID
#
class Thrift::AMQP::PrivateEndpoint < Thrift::AMQP::BaseEndpoint
  def initialize(connection, exchange, exchange_name)
    super(connection, exchange, exchange_name)

    @uuid = UUID.new

    @queue_name = _private_endpoint_name(@exchange_name)
  end
  
  def create_queue
    queue = @connection.queue(
      queue_name, 
      :auto_delete => true, 
      :exclusive   => true)
      
    queue
  end
  
  def bind_queue
    queue.bind(exchange)
  end
  
  def _private_endpoint_name(base_name) 
    [
      base_name, 
      'private', 
      @uuid.generate].join('_')
  end
end