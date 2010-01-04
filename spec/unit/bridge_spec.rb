require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp'

describe TOAMQP::Bridge do
  attr_reader :connection, :exchange, :queue
  attr_reader :bridge
  before(:each) do
    @connection = flexmock(:connection)
    @exchange   = flexmock(:exchange)
    @queue      = flexmock(:queue)
    
    connection.should_receive(
      :exchange => @exchange, 
      :queue    => @queue).by_default
      
    queue.should_receive(
      :name     => 'anonymous_queue_1', 
      :bind     => nil).by_default
      
    @bridge = TOAMQP::Bridge.new(connection, 'exchange_name', {})
  end
  
  describe "#exchange_name" do
    it "should always be converted to a string" do
      TOAMQP::Bridge.new(connection, :exchange_name, {}).exchange_name.should == 'exchange_name'
    end 
  end
  describe "#protocol" do
    before(:each) do
      flexmock(bridge, 
        :source => flexmock(:source, 'queue.name' => 'private_queue'), 
        :destination => flexmock(:destination))
    end
    def call
      bridge.protocol
    end
    
    it "should return an instance of Thrift::BinaryProtocol" do
      call.should be_an_instance_of(Thrift::BinaryProtocol)
    end 
  end
  describe "#transport" do
    before(:each) do
      flexmock(bridge, 
        :source => flexmock(:source, 'queue.name' => 'private_queue'), 
        :destination => flexmock(:destination))
    end
    def call
      bridge.transport
    end

    it "should return a Transport" do
      call.should be_an_instance_of(TOAMQP::Transport)
    end 
  end
  describe "#source" do
    it "should return a TOAMQP::Source::PrivateQueue" do
      bridge.source.should be_an_instance_of(TOAMQP::Source::PrivateQueue)
    end 
  end
  describe "#destination" do
    attr_reader :destination
    before(:each) do
      @destination = bridge.destination('reply_queue')
    end
    it "should return a TOAMQP::Target::Generic" do
      destination.should be_an_instance_of(TOAMQP::Target::Generic)
    end
    it "should have a reply_to queue name in headers" do
      destination.headers.keys.should include("reply_to")
    end 
  end
  
  context "when constructed with additional headers to send" do
    before(:each) do
      @bridge = TOAMQP::Bridge.new(connection, 'exchange_name', { :foo => :bar })
    end
    
    it "should construct the exchange to be a headers exchange" do
      connection.should_receive(:exchange).
        with('exchange_name', :type => :headers).and_return(exchange)
        
      bridge.destination('test')
    end 
  end
end