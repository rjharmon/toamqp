require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thrift::AMQP::Connection do
  attr_reader :connection, :bunny, :exchange
  before(:each) do
    @connection = Thrift::AMQP::Connection.new

    # Mocking out the AMQP connection completely, since we only want to see
    # if the parts go where they must.
    @bunny      = flexmock(:bunny)
    @exchange   = flexmock(:bunny_exchange)
      
    bunny.should_receive(:exchange => exchange)
    exchange.should_receive(:name => 'service_name')
    
    flexmock(connection).should_receive(:connection => bunny).by_default
  end
  
  describe ".service" do
    attr_reader :service
    before(:each) do
      @service = connection.service('service_name')
    end
    
    it "should return a Service instance" do
      service.should be_an_instance_of(Thrift::AMQP::Service)
    end

    describe "#endpoint" do
      it "should return an Endpoint instance"
      it "should have a queue name that matches the exchange name"
    end
    describe "#endpoint(filter)" do
      it "should return an Endpoint instance"
      it "should have a queue name that is unique for the given filter"
    end
    describe "#private_endpoint" do
      it "should return an Endpoint instance"
      it "should have a private name based on the exchange and an UUID" 
    end

    describe "#transport" do
      attr_reader :transport
      before(:each) do
        @transport = service.transport
      end
      
      it "should connect to exchange 'service_name'" do
        transport.exchange.name.should == 'service_name'
      end 
    end
  end
end