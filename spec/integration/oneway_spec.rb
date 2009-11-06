require File.dirname(__FILE__) + '/../spec_helper'

require 'active_support'

$:.unshift File.dirname(__FILE__) + "/gen-rb"
begin
  require 'test'
rescue LoadError
  puts "No test interface found. Maybe you should run 'rake thrift' first?"
end

describe "AMQP Transport Integration (oneway)" do
  EXCHANGE_NAME = 'integration_spec_oneway'
  attr_reader :connection
  before(:each) do
    @connection_credentials = {
      :host => 'localhost', 
      :vhost => '/'
    }
    
    filename = PROJECT_BASE + "/connection.yml"
    if File.exist?(filename)
      settings = YAML.load(File.read(filename))
      
      @connection_credentials = HashWithIndifferentAccess.new(settings)[:connection]
    end
    
    @connection = Thrift::AMQP::Connection.start(@connection_credentials)
  end
  
  # Sets up a client for the given header filter. 
  #
  def client_for(headers={})
    begin
      transport = connection.client_transport(EXCHANGE_NAME, headers)
      protocol = Thrift::BinaryProtocol.new(transport)
      
      Test::Client.new(protocol)
    rescue Bunny::ServerDownError
      raise "Could not connect - is your local RabbitMQ running?"
    ensure 
      transport.open
    end
  end
  
  # A handler class that will help with testing. 
  #
  class SpecHandler
    attr_reader :messages
    def initialize
      @messages = []
    end
    def sendMessage(message)
      @messages << message
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
      @server_transport = connection.server_transport(EXCHANGE_NAME, headers)
    end
    
    # Spins the server and makes it read the next +message_count+ messages.
    #
    def spin_server
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
    
  context 'with a server in the background' do
    attr_reader :server, :client
    before(:each) do
      # Server setup
      @server = SpecTestServer.new(connection)
      
      @client = client_for()
    end
    after(:each) do
      @server.close
    end
    
    it "should successfully send a message" do
      client.sendMessage("a message")

      server.spin_server
      server.handler.messages.should include('a message')
    end 
    it "should send several messages" do
      10.times do |i|
        client.sendMessage("a message (#{i})")
      end

      server.spin_server
      server.handler.messages.should have(10).messages
    end 
    context "with a second server" do
      attr_reader :second_server
      before(:each) do
        # Server setup
        @second_server = SpecTestServer.new(connection)
      end
      after(:each) do
        second_server.close
      end
      
      it "should allow only one server to receive the message/call" do
        10.times do |i|
          client.sendMessage("a message (#{i})")
        end

        server.spin_server
        second_server.spin_server
        
        messages = server.handler.messages + second_server.handler.messages
        10.times do |i|
          messages.should include("a message (#{i})")
        end          
      end 
    end
  end
  context 'with two servers, one for dogs and one for cats' do
    attr_reader :dog_server, :cat_server
    attr_reader :dog_client, :cat_client
    before(:each) do
      @dog_server, @cat_server = [:dog, :cat].
        map { |type| SpecTestServer.new(connection, :type => type) }
        
      @dog_client, @cat_client = [:dog, :cat].
        map { |type| client_for(:type => type) }
    end
    after(:each) do
      dog_server.close
      cat_server.close
    end
    
    context "messages sent to dog" do
      before(:each) do
        dog_client.sendMessage("wuff")
        
        # Cat goes first, if filter is ineffective, messages will end up on cat.
        cat_server.spin_server
        dog_server.spin_server
      end
      
      it "should be received by dog" do
        dog_server.handler.messages.should include('wuff')
      end
      it "should not be received by cat" do
        cat_server.handler.messages.should_not include('wuff')
      end
    end
  end
end