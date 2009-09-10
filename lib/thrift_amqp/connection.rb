

# Connection to the AMQP server and a factory for all the transports you 
# might eventually need. 
#
class Thrift::AMQP::Connection 
  # Connects to a AMQP server. 
  #
  # Parameters: 
  # 
  #   +host+  :: host your AMQP server is running on
  #   +vhost+ :: virtual host to connect to 
  #   +user+  :: user to connect with
  #   +password+ :: password to use for the connection.
  #
  def initialize(credentials)
  end
  
  # Constructs and returns a server transport for use with any of thrifts
  # server implementations. In the perspective of this class, a server is 
  # receiving calls through the queue and does something with them. 
  #
  # Parameters: 
  #   +queue_name+ :: queue to connect to
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
  def server_transport(queue_name)
    
  end
  
  # Constructs and returns a client transport for use with the client 
  # thrift generates for your service. 
  #
  # Parameters: 
  #   +queue_name+ :: queue to connect to
  #
  # Example: 
  #
  #   transport = connection.client_transport('battle_cry')
  #   protocol  = Thrift::BinaryProtocol.new(transport)
  #   client    = AwesomeService::Client.new(protocol)
  #   
  #   client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server
  #
  def client_transport(queue_name)
    
  end
end