require File.dirname(__FILE__) + '/../spec_helper'

$:.unshift File.dirname(__FILE__) + "/gen-rb"
begin
  require 'test'
rescue LoadError
  puts "No test interface found. Maybe you should run 'rake thrift' first?"
end

describe "AMQP Transport Integration (oneway)" do
  EXCHANGE_NAME = 'integration_spec_oneway'
  
  class SpecHandler
    attr_reader :messages
    def initialize
      @messages = []
    end
    def sendMessage(message)
      @messages << message
    end
  end
  
  class SpecTestServer 
    attr_reader :handler
    def initialize()
      @handler = SpecHandler.new()
      @processor = Test::Processor.new(handler)
      @server_transport = Thrift::AMQP::ServerTransport.new(EXCHANGE_NAME)
    end
    
    # Spins the server and makes it read the next +message_count+ messages.
    #
    def spin_server(message_count)
      @server_transport.listen
      client = @server_transport.accept
      prot = Thrift::BinaryProtocol.new(client)
      
      messages_left = message_count
      while messages_left > 0
        @processor.process(prot, prot)
        messages_left -= 1
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
      @server = SpecTestServer.new
      
      # Client setup
      begin
        @transport = Thrift::AMQP::Transport.connect(EXCHANGE_NAME)
        protocol = Thrift::BinaryProtocol.new(@transport)
        @client = Test::Client.new(protocol)
      rescue Bunny::ServerDownError
        raise "Could not connect - is your local RabbitMQ running?"
      end

      @transport.open
    end
    after(:each) do
      @server.close
      @transport.close
      
      # Try to kill the exchange and the queue 
      connection = Bunny.new 
      # connection.start
      # 
      # # connection.exchange(EXCHANGE_NAME, :type => :fanout).delete
      # # connection.queue(EXCHANGE_NAME).delete
      # 
      # connection.stop
    end
    
    it "should successfully send a message" do
      client.sendMessage("a message")

      server.spin_server 1
      server.handler.messages.should include('a message')
    end 
    it "should send several messages" do
      10.times do |i|
        client.sendMessage("a message (#{i})")
      end

      server.spin_server 10
      server.handler.messages.should have(10).messages
    end 
    context "with a second server" do
      attr_reader :second_server
      before(:each) do
        # Server setup
        @second_server = SpecTestServer.new
      end
      after(:each) do
        second_server.close
      end
      
      it "should allow only one server to receive the message/call" do
        10.times do |i|
          client.sendMessage("a message (#{i})")
        end

        server.spin_server 5
        second_server.spin_server 5
        
        messages = server.handler.messages + second_server.handler.messages
        10.times do |i|
          messages.should include("a message (#{i})")
        end          
      end 
    end
  end
end