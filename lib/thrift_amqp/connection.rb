

# Connection to the AMQP server and a factory for all the transports you 
# might eventually need. 
#
class Thrift::AMQP::Connection 
  def initialize(credentials = {})
    @credentials = credentials.inject({}) { 
      |hash, (k,v)| 
      hash[k.to_sym] = v
      hash
    }
    @credentials[:pass] = @credentials.delete(:password) || ''
  end
  
  # Internal command to create and start the connection. 
  #
  def start
    @connection = Bunny.new(@credentials)
    @connection.start    
    
    self
  end

  # Connects to a AMQP server. 
  #
  # Parameters: 
  # 
  #   +host+  :: host your AMQP server is running on
  #   +vhost+ :: virtual host to connect to 
  #   +user+  :: user to connect with
  #   +password+ :: password to use for the connection.
  #
  def self.start(credentials = {})
    new(credentials).start
  end
  
  # Constructs and returns a server transport for use with any of thrifts
  # server implementations. In the perspective of this class, a server is 
  # receiving calls through the queue and does something with them. 
  #
  # Parameters: 
  #   +queue_name+ :: queue to connect to
  #   +headers+    :: set of headers that all received messages must have
  #
  # Example:
  #
  #   class MyAwesomeHandler
  #     def battleCry(message)
  #       puts messages
  #     end
  #   end
  # 
  #   handler           = MyAwesomeHandler.new()
  #   processor         = AwesomeService::Processor.new(handler)
  #   server_transport  = connection.server_transport('battle_cry')
  # 
  #   server = Thrift::SimpleServer.new(processor, transport)
  # 
  #   server.serve    # never returns
  #
  def server_transport(queue_name, headers={})
    Thrift::AMQP::ServerTransport.new(
      *create_exchange_and_queue(queue_name, headers))
  end
  
  # Constructs and returns a client transport for use with the client 
  # thrift generates for your service. 
  #
  # Parameters: 
  #   +queue_name+ :: queue to connect to
  #   +headers+    :: set of headers that all sent messages have
  #
  # Example: 
  #
  #   transport = connection.client_transport('battle_cry')
  #   protocol  = Thrift::BinaryProtocol.new(transport)
  #   client    = AwesomeService::Client.new(protocol)
  #   
  #   client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server
  #
  def client_transport(queue_name, headers={})
    Thrift::AMQP::Transport.new(
      *create_exchange_and_queue(queue_name, headers))
  end
  
  def create_exchange_and_queue(queue_name, headers)
    exchange = begin
      @connection.exchange(queue_name, 
        :type => :fanout)
    rescue Bunny::ProtocolError
      raise "Could not create exchange #{@exchange_name}, maybe it exists (with different params)?"
    end

    # Make sure the queue exists. The server doesn't use this, but no harm 
    # in creating this anyway. 
    queue = @connection.queue(queue_name, 
      :auto_delete => true)
    queue.bind(exchange)

    [exchange, queue]
  end
end