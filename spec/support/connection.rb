
require 'active_support'

module AMQPHelpers
  # Centralizing the code that connects to AMQP server during test. This
  # returns a Connection instance.
  #
  def connect_for_integration_test
    connection_credentials = {
      :host => 'localhost', 
      :vhost => '/'
    }
  
    filename = PROJECT_BASE + "/connection.yml"
    if File.exist?(filename)
      settings = YAML.load(File.read(filename))
    
      connection_credentials = HashWithIndifferentAccess.new(settings)[:connection]
    end
  
    Thrift::AMQP.start(connection_credentials)
  end

  # Sets up a client for the given header filter. 
  #
  def client_for(headers={})
    begin
      service = connection.service(EXCHANGE_NAME)
      transport = service.client_transport(headers)
      protocol = Thrift::BinaryProtocol.new(transport)
      
      Test::Client.new(protocol)
    rescue Bunny::ServerDownError
      raise "Could not connect - is your local RabbitMQ running?"
    ensure 
      transport.open
    end
  end
end