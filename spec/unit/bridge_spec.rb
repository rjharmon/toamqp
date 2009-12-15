require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp/client'

describe TOAMQP::Bridge do
  attr_reader :connection
  before(:each) do
    @connection = flexmock(:connection)
  end
  
  def bridge
    TOAMQP::Bridge.new(connection, 'exchange_name')
  end
  
  describe "#protocol" do
    def call
      bridge.protocol
    end
    
    it "should return an instance of Thrift::BinaryProtocol" do
      call.should be_an_instance_of(Thrift::BinaryProtocol)
    end 
  end
end