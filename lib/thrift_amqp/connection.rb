require 'uuid'

# Connection to the AMQP server and a factory for all the transports you 
# might eventually need. 
#
class Thrift::AMQP::Connection 
  def initialize(credentials = {})
    @uuid_generator = UUID.new
    
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
  #   +exchange_name+ :: exchange to connect to
  #   +headers+       :: set of headers that all received messages must have
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
  def server_transport(exchange_name, headers={})
    exchange = _create_exchange(exchange_name)
    
    Thrift::AMQP::ServerTransport.new(
      exchange, 
      _create_queue(exchange, exchange_name, headers))
  end
  
  # Constructs and returns a client transport for use with the client 
  # thrift generates for your service. 
  #
  # Parameters: 
  #   +exchange_name+ :: exchange to connect to
  #   +headers+       :: set of headers that all sent messages have
  #
  # Example: 
  #
  #   transport = connection.client_transport('battle_cry')
  #   protocol  = Thrift::BinaryProtocol.new(transport)
  #   client    = AwesomeService::Client.new(protocol)
  #   
  #   client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server
  #
  def client_transport(exchange_name, headers={})
    Thrift::AMQP::Transport.new(
      _create_exchange(exchange_name),
      nil, 
      stringify(headers))
  end

  def _create_exchange(name)
    begin
      @connection.exchange(name, 
        :type => :headers)
    rescue Bunny::ProtocolError
      raise "Could not create exchange #{@exchange_name}, maybe it exists (with different params)?"
    end
  end
  def _create_queue(exchange, base_name, headers) 
    queue = @connection.queue(
      queue_name(base_name), 
      :auto_delete => true)
          
    queue.bind(exchange, 
      :arguments => stringify(headers).merge('x-match'=>'all'))
      
    queue
  end
  
  # Generates a globally unique queue name for a given exchange name. 
  # This ensures that the server that uses this will get his messages, 
  # even if there are other servers connected to the same exchange.
  #
  def queue_name(exchange_name)
    "%s-%s" % [
      exchange_name, 
      @uuid_generator.generate]
  end
  
  # Returns a duplicate of the hash, where keys and values are turned into
  # strings.
  #
  def stringify(hash)
    stringified = hash.
      inject({}) { |new_hash, (key, value)| 
        new_hash[key.to_s] = value.to_s
        new_hash }
  end
end