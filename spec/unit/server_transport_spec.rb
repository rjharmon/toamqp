require File.dirname(__FILE__) + '/../spec_helper'

describe Thrift::AMQP::ServerTransport do
  context '#new(exchange)' do
    attr_reader :transport
    attr_reader :queue, :exchange

    before(:each) do
      @exchange = flexmock(:exchange)
      @queue    = flexmock(:queue)
      @transport = Thrift::AMQP::ServerTransport.new(flexmock(:exchange), flexmock(:queue))
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