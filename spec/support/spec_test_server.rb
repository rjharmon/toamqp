$:.unshift File.dirname(__FILE__) + "/gen-rb"
begin
  require 'test'
rescue LoadError
  puts "No test interface found. Maybe you should run 'rake thrift' first?"
end

# A handler class that will help with testing. 
#
class SpecHandler
  attr_reader :messages
  def initialize
    @messages = []
  end
  
  def sendMessage(message)
    @messages << message
  end
  
  def capitalize(string)
    string.capitalize
  end
end

# A server class that allows limited runs of the server loop. 
#
class SpecTestServer 
  attr_reader :handler
  
  # Creates a test server that will process messages and then quit. 
  #
  def initialize(connection, headers = {})
    @handler = SpecHandler.new()
    @processor = Test::Processor.new(handler)
    @server_transport = connection.service(EXCHANGE_NAME).endpoint(headers).transport
  end
  
  # Spins the server and makes it read the next +message_count+ messages.
  #
  def spin
    @server_transport.listen
    client = @server_transport.accept
    prot = Thrift::BinaryProtocol.new(client)
          
    while @server_transport.waiting?
      @processor.process(prot, prot)
    end
  ensure
    client.close
  end
  
  def close
    @server_transport.close
  end
end
    
