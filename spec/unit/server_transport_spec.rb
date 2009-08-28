require File.dirname(__FILE__) + '/../spec_helper'

describe Thrift::AMQP::ServerTransport do
  it "should be constructed with an exchange name" do
    Thrift::AMQP::ServerTransport.new('exchange')
  end 
  it "should be constructed with an exchange and a set of headers" do
    Thrift::AMQP::ServerTransport.new('exchange', :foo => :bar)
  end 
  
  context '#new(exchange)' do
    attr_reader :transport
    attr_reader :bunny, :queue, :exchange

    before(:each) do
      @transport = Thrift::AMQP::ServerTransport.new('exchange')

      # Stub Bunny subsystem
      @bunny = flexmock(:bunny)
      @exchange = flexmock(:exchange, :name => 'exchange')
      @queue = flexmock(:queue)
      
      set_defaults(bunny, 
        :start => nil, 
        :exchange => exchange, 
        :queue => queue)

      set_defaults(queue, 
        :bind => nil)

      flexmock(Bunny, :new => bunny)
    end

    describe "#listen (1: setup the connection)" do
      it "should create a bunny connection" do
        bunny.should_receive(:start).once
        
        transport.listen
      end 
      it "should create an exchange of type headers" do
        bunny.should_receive(:exchange).with('exchange', Hash).once
        
        transport.listen
      end 
    end
    describe "#accept (2: accept a connection, returns a transport)" do
      before(:each) do
        transport.listen
      end
      it "should return a queue transport" do
        transport.accept.should be_instance_of(Thrift::AMQP::Transport)
      end 
    end
    describe "#close (3: closes the server)" do
      before(:each) do
        transport.listen
      end

      it "should not fail" do
        transport.close
      end
    end
  end
end