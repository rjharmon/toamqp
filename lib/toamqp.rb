
require 'thrift'

# Root module for the Thrift Over AMQP framework.
module TOAMQP; 
  module Service; end;
  module Target; end;
  
  def client(exchange_name, protocol_module)
    connection = TOAMQP.spawn_connection
    
    amqp_bridge = TOAMQP::Bridge.new(connection, exchange_name)
    client_class = protocol_module.const_get('Client')
    
    client_class.new(amqp_bridge.protocol)
  end
  
  # Returns a new server that serves +service+.
  #
  # Example:
  #
  #   class MyService < TOAMQP::Service::Base
  #     serves Service    # the module that contains thrift classes
  #     exchange :service
  #   end
  #
  #   # Launches the server (a simple one) in one line
  #   TOAMQP.server(MyService.new).serve
  #
  def server(service, server_klass=Thrift::SimpleServer)
    processor = service.thrift_processor
    transport = service.server_transport
        
    server_klass.new processor, transport
  end
  
  module_function :server, :client
end

require 'toamqp/uuid_generator'
require 'toamqp/service/base'
require 'toamqp/connection_manager'

require 'toamqp/server_transport'

require 'toamqp/bridge'
require 'toamqp/sources'
require 'toamqp/targets'

require 'toamqp/topology'
