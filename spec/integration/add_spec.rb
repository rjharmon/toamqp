require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp/server'
require 'toamqp/client'

describe "Server of test service" do
  class TestService < TOAMQP::Service::Base
    exchange :test
    
    def announce(msg)
    end
    def add(a,b)
      a+b
    end
  end
  
  attr_reader :server, :client
  before(:each) do
    @server = TOAMQP::Server.create(TestService.new)
    @client = TOAMQP::Client.new('test', Test)
  end
  
  context "oneway #announce" do
    it "should transmit message" do
      client.announce('foo')
      server.run_until_queue_empty

      received_messages.should include('foo')
    end
    it "should return without waiting for answer (asynchronous operation)" do
      client.announce('foo')
      client.announce('bar')

      # Since we didn't wait for the server, it didn't do the work.
      received_messages.should be_empty
    end
  end
  context "twoway #add" do
    context "call with (13, 29)" do
      def call
        client.add(13, 29)
      end
      
      it "should return 42" do
        call.should == 42
      end 
    end
  end
end