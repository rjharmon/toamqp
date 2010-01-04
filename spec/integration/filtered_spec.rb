require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

describe "Filtering" do
  TIMEOUT = 1
  
  # Define a small service that allows inspection of the service methods. 
  # This is used in all the following tests. See also protocol/test.thrift
  #
  class FilterForBaseService < TOAMQP::Service::Base
    serves Test

    def initialize(spool)
      super()
      @spool = spool
    end
    
    def announce(msg)
      @spool << msg
    end
  end
  
  class FilterForBarService < FilterForBaseService
    exchange :test_filtered, :match => { :foo => :bar }
  end
  
  class FilterForBazService < FilterForBaseService
    exchange :test_filtered, :match => { :foo => :baz }
  end

  after(:each) do
    Bunny.run do |mq|
      %w{
        test_filtered-foo_baz
        test_filtered-foo_bar
      }.each do |queue_name|
        queue = mq.queue(queue_name)
        queue.pop while queue.message_count > 0
        queue.delete
      end        
    end
  end
  
  context "using a single server" do
    attr_reader :server, :received
    before(:each) do
      @received = []
      @server = TOAMQP.server(FilterForBarService.new(received), TOAMQP::SpecServer)
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
  context "using two competing servers", "messages sent with :bar" do
    attr_reader :bar, :baz
    before(:each) do
      @bar = []
      @baz = []
      
      @bar_server = TOAMQP.server(FilterForBarService.new(bar), TOAMQP::SpecServer)
      @baz_server = TOAMQP.server(FilterForBazService.new(baz), TOAMQP::SpecServer)

      client = TOAMQP.client(:test_filtered, Test, :header => { :foo => :bar })
      client.announce('message')

      @baz_server.serve
      @bar_server.serve
    end

    it "should be received by FilterForBarService" do
      bar.should include('message')
    end 
    it "should not be received by FilterForBazService" do
      baz.should_not include('message')
    end 
  end
end