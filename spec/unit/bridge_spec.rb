require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp'

describe TOAMQP::Bridge do
  attr_reader :connection, :bridge
  before(:each) do
    @connection = flexmock(:connection, 
      :exchange => flexmock(:exchange), 
      :queue    => flexmock(:queue))
      
    @bridge = TOAMQP::Bridge.new(connection, 'exchange_name')
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
    it "should return a TOAMQP::Target::Exchange" do
      bridge.destination.should be_an_instance_of(TOAMQP::Target::Exchange)
    end
  end
end