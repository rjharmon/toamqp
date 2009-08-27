require File.dirname(__FILE__) + '/../spec_helper'

$:.unshift File.dirname(__FILE__) + "/gen-rb"
require 'test'

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
  
  context 'with a server in the background' do
    attr_reader :handler, :client
    before(:each) do
      # Server setup
      @handler = SpecHandler.new()
      @processor = Test::Processor.new(handler)
      @server_transport = Thrift::AMQP::ServerTransport.new(EXCHANGE_NAME)
      
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
      @transport.close
    end
    
    # Spins the server and makes it read the next +times+ messages.
    #
    def spin_server(times)
      begin
        @server_transport.listen
        client = @server_transport.accept
        prot = Thrift::BinaryProtocol.new(client)

        while times > 0
          @processor.process(prot, prot)
          times -= 1
        end
      ensure
        @server_transport.close
      end
    end
    
    it "should successfully send a message" do
      client.sendMessage("a message")
      spin_server 1
      
      handler.messages.should include('a message')
    end 
    it "should send several messages" do
      10.times do |i|
        client.sendMessage("a message (#{i})")
      end
      spin_server 10
      
      handler.messages.should have(10).messages
    end 
  end
end