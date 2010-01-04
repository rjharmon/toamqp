require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

describe "Server of test service" do
  TIMEOUT = 1
  
  # Define a small service that allows inspection of the service methods. 
  # This is used in all the following tests. See also protocol/test.thrift
  #
  class TestService < TOAMQP::Service::Base
    serves Test
    exchange :test
    
    def initialize(spool)
      super()
      
      @spool = spool
    end
    
    def announce(msg)
      @spool << msg
    end
    def add(a,b)
      a+b
    end
  end
  
  attr_reader :server, :client, :handler
  attr_reader :received_messages
  before(:each) do
    # A buffer for messages sent to #announce
    @received_messages = []
    
    @handler = TestService.new(received_messages)
    
    @server = TOAMQP.server(@handler, TOAMQP::SpecServer)
    @client = TOAMQP.client('test', Test)
  end
  after(:each) do
    server.close
    Bunny.run do |conn|
      queue = conn.queue('test')
      queue.purge
    end
  end
  
  context "oneway #announce" do
    it "should transmit message" do
      client.announce('foo')
      server.serve

      received_messages.should include('foo')
    end
    it "should return without waiting for answer (asynchronous operation)" do
      client.announce('foo')
      client.announce('bar')

      # Since we didn't wait for the server, it didn't do the work.
      received_messages.should be_empty
    end
    it "should transmit hundreds of messages" do
      100.times do |i|
        client.announce("message #{i}")
      end
      server.serve
      
      received_messages.should have(100).messages
    end 
    context "server" do
      it "should receive the call" do
        flexmock(handler).
          should_receive(:announce).once
        
        client.announce('foo')
        server.serve
      end 
    end
  end
  context "twoway #add" do
    before(:each) do
      server.serve_in_thread
    end
    after(:each) do
      server.stop_and_join
    end
    
    context "call with (13, 29)" do
      def call
        timeout(TIMEOUT) do
          client.add(13, 29)
        end
      end

      it "should return 42" do
        call.should == 42
      end 
    end
    it "should allow multiple calls" do
      timeout(TIMEOUT) do
        client.add 1,2
        client.add 1,3
      end
    end
  end    
end