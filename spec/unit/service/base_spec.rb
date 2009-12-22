require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TOAMQP::Service::Base do

  context "test service instance" do
    module Test
      class Processor
        include ::Thrift::Processor
      end
    end
    
    class TestService < TOAMQP::Service::Base
      serves Test
    end
    
    attr_reader :instance
    before(:each) do
      @instance = TestService.new
    end
    
    describe "#thrift_processor" do
      it "should return a Thrift::Processor" do
        instance.thrift_processor.should be_a_kind_of(Thrift::Processor)
      end
    end
    describe "#server_transport" do
      it "should return a ServerTransport" do
        instance.server_transport.should be_an_instance_of(TOAMQP::ServerTransport)
      end 
    end
  end
  
  
end