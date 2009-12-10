# Centralizing the code that connects to AMQP server during test. This returns
# a Connection instance.
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
