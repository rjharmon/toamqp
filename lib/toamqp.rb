
require 'thrift'

# Root module for the Thrift Over AMQP framework.
module TOAMQP; 
  module Service; end;
  module Target; end;
  
  # Returns a client for a service that is attached to +exchange_name+. The 
  # client will use the thrift module +protocol_module+. 
  #
  # Example:
  #
  #   # Returns a client for Test
  #   TOAMQP.client('service_name', Test)
  #
  def client(exchange_name, protocol_module, opts={})
    connection = TOAMQP.spawn_connection
    
    additional_headers = opts[:header] || {}
    
    amqp_bridge = TOAMQP::Bridge.new(
      connection, 
      exchange_name, 
      additional_headers)
      
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

require 'toamqp/util'
require 'toamqp/uuid_generator'
require 'toamqp/service/base'
require 'toamqp/connection_manager'

require 'toamqp/server_transport'

require 'toamqp/bridge'
require 'toamqp/sources'
require 'toamqp/targets'

require 'toamqp/topology'
