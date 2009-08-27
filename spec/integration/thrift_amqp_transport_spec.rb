require File.dirname(__FILE__) + '/../spec_helper'

$:.unshift File.dirname(__FILE__) + "/gen-rb"
require 'test'

describe "AMQP Transport Integration (oneway)" do
  EXCHANGE_NAME = 'integration_spec_oneway'
  
  class SpecHandler
    attr_reader :messages
    def initialize
      @message = []
    end
    def sendMessage(message)
      @messages << messages
    end
  end
  
  context 'with a server in the background' do
    attr_reader :handler
    before(:each) do
      @handler = SpecHandler.new()
      @processor = Test::Processor.new(handler)
      @server_transport = Thrift::AMQP::ServerTransport.new(EXCHANGE_NAME)
    end
    
    it "should successfully send a message" do
      client.sendMessage("a message")
      
      handler.messages.should include('a message')
    end 
    it "should send several messages" do
      10.times do |i|
        client.sendMessage("a message (#{i})")
      end
      
      handler.messages.should have(10).messages
    end 
  end
end