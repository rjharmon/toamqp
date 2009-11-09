require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thrift::AMQP::Connection do
  attr_reader :connection, :bunny, :exchange, :queue
  before(:each) do
    @connection = Thrift::AMQP::Connection.new

    # Mocking out the AMQP connection completely, since we only want to see
    # if the parts go where they must.
    @bunny      = flexmock(:bunny)
    @exchange   = flexmock(:bunny_exchange)
    @queue      = flexmock(:bunny_queue)
      
    bunny.should_receive(:exchange => exchange)
    exchange.should_receive(:name => 'service_name')
    
    bunny.should_receive(:queue => queue)
    queue.should_receive(:bind)
    
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
      attr_reader :endpoint
      before(:each) do
        @endpoint = service.endpoint
      end
      
      it "should return an Endpoint instance" do
        endpoint.should be_an_instance_of(Thrift::AMQP::Endpoint)
      end

      describe "#queue_name" do
        it "should match the exchange name" do
          endpoint.queue_name.should == 'service_name'
        end
      end
      describe "#transport" do
        attr_reader :transport
        before(:each) do
          @transport = endpoint.transport 
        end
        
        it "should be an instance of ServerTransport" do
          transport.should be_an_instance_of(Thrift::AMQP::ServerTransport)
        end 
      end
      describe "#stringify" do
        attr_reader :result
        before(:each) do
          @result = endpoint.stringify(:foo => :bar)
        end
        
        it "should stringify keys" do
          result.keys.should include('foo')
        end
        it "should stringify values" do
          result.values.should include('bar')
        end
      end
    end
    describe "#endpoint(filter)" do
      attr_reader :endpoint
      before(:each) do
        @endpoint = service.endpoint(:foo => :bar)
      end
      
      it "should return an Endpoint instance" do
        endpoint.should be_an_instance_of(Thrift::AMQP::Endpoint)
      end
      describe "#queue_name" do
        it "should match the exchange name plus the filter options" do
          endpoint.queue_name.should == 'service_name_foo_bar'
        end
      end
    end
    describe "#private_endpoint" do
      attr_reader :endpoint
      before(:each) do
        @endpoint = service.private_endpoint
      end
      
      it "should return an PrivateEndpoint instance" do
        endpoint.should be_an_instance_of(Thrift::AMQP::PrivateEndpoint)
      end
      it "should have a private name based on the exchange and an UUID" do
        uuid = /[0-9a-f-]+/
        endpoint.queue_name.should match(/service_name_private_#{uuid}/)
      end
    end

    describe "#transport" do
      attr_reader :transport
      before(:each) do
        @transport = service.transport
      end
      
      it "should connect to exchange 'service_name'" do
        transport.exchange.name.should == 'service_name'
      end 
      it "should be an instance of Thrift::AMQP::Transport" do
        transport.should be_an_instance_of(Thrift::AMQP::Transport)
      end 
    end
  end
end