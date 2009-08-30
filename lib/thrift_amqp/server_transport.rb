

# Server transport for using oneway thrift over an AMQP-queue. 
#
# Example: 
#
#   class MyAwesomeHandler
#     def battleCry(message)
#       puts messages
#     end
#   end
# 
#   handler = MyAwesomeHandler.new()
#   processor = AwesomeService::Processor.new(handler)
# 
#   # Connecting to the exchange called 'battle_cry'. This must match the
#   # clients setting.    
#   server_transport = Thrift::AMQP::ServerTransport.new('battle_cry')
# 
#   server = Thrift::SimpleServer.new(processor, transport)
# 
#   server.serve    # never returns
#
class Thrift::AMQP::ServerTransport < Thrift::BaseServerTransport
  # Initializes a connection to the AMQP queue. If you provide a headers 
  # argument, only messages that match ALL headers will be accepted. 
  #
  # Example: 
  #
  #   Thrift::AMQP::ServerTransport.new('queue', :version => 1)
  #   # Will only match messages that have 'version' == '1'
  # 
  def initialize(exchange_name, headers={})
    @exchange_name = exchange_name
    @header_filter = transform_hash_to_string(headers)
  end
  
  # Part of the server 
  def listen
    @transport = Thrift::AMQP::Transport.connect(@exchange_name)
  end

  def accept
    @transport
  end
private
  def transform_hash_to_string(hash)
    hash.inject({}) do |new_hash, (k,v)|
      new_hash[k.to_s] = v.to_s

      new_hash
    end
  end
end