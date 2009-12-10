require File.dirname(__FILE__) + '/../spec_helper'

require 'support/spec_test_server'

describe "AMQP Transport Integration (oneway)" do
  include AMQPHelpers
  
  EXCHANGE_NAME = 'integration_spec_oneway'
  attr_reader :connection
  before(:each) do
    @connection = connect_for_integration_test
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
  
      server.spin
      server.handler.messages.should include('a message')
    end 
    it "should send several messages" do
      10.times do |i|
        client.sendMessage("a message (#{i})")
      end
  
      server.spin
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
  
        server.spin
        second_server.spin
        
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
        map { |type| SpecTestServer.new(connection, false, :type => type) }
        
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
        cat_server.spin
        dog_server.spin
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