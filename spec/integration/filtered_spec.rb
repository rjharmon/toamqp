require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

describe "Filtered server" do
  TIMEOUT = 1
  
  # Define a small service that allows inspection of the service methods. 
  # This is used in all the following tests. See also protocol/test.thrift
  #
  class FilteredTestService < TOAMQP::Service::Base
    serves Test
    exchange :test_filtered, :match => { :foo => :bar }
    
    def initialize(spool)
      super()
      @spool = spool
    end
    
    def announce(msg)
      @spool << msg
    end
  end
  
  attr_reader :server, :received
  before(:each) do
    @received = []
    @server = TOAMQP.server(FilteredTestService.new(received), SpecServer)
  end
  
  context "when sent messages with :foo => :bar" do
    before(:each) do
      client = TOAMQP.client(:test_filtered, Test, :header => { :foo => :bar })
      client.announce('message')
      
      server.serve
    end
    it "should receive the message" do
      received.should include('message')
    end
  end
  context "when sent messages with :foo => :baz" do
    before(:each) do
      client = TOAMQP.client(:test_filtered, Test, :header => { :foo => :baz })
      client.announce('message')

      server.serve
    end
    it "should not receive the message" do
      received.should_not include('message')
    end
  end
end