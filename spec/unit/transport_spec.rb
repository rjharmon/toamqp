require File.dirname(__FILE__) + '/../spec_helper'

describe Thrift::AMQP::Transport, 'when constructed with an exchange (server)' do
  attr_reader :transport, :connection, :exchange, :queue
  before(:each) do
    @exchange = flexmock(:exchange)
    @queue = flexmock(:queue)

    exchange.should_receive(
      :name => 'exchange').by_default
    
    # Stub an interface for the queue
    queue.should_receive(
      :bind => nil, 
      :pop  => :queue_empty).by_default
    
    @transport = Thrift::AMQP::Transport.new(exchange, queue)
  end
  
  describe "#read(sz)" do
    it "should poll for a new message on the queue" do
      queue_empty_message = { :payload => :queue_empty }
      message_message = { :payload => 'message' }
      queue.should_receive(:pop).
        and_return(queue_empty_message, queue_empty_message, message_message)
      
      transport.read(1).should == 'm'
    end
    it "should return sz bytes" do
      queue.should_receive(:pop).and_return(:payload => ' '*1000)
      
      transport.read(999).size.should == 999
      transport.read(10).size.should == 1
    end
    it "should return at most the whole message" do
      queue.should_receive(:pop).and_return(:payload => ' '*1000)
      
      transport.read(2000).size.should == 1000
    end
  end
end

describe Thrift::AMQP::Transport, 'when using .connect (client)' do
  attr_reader :bunny, :exchange, :queue
  before(:each) do
    @exchange = flexmock(:exchange)
    @queue = flexmock(:queue)
    
    queue.should_receive(
      :bind => nil).by_default
    
    exchange.should_receive(
      :name => 'exchange').by_default
  end
  
  context 'connected' do
    attr_reader :transport
    before(:each) do
      @transport = Thrift::AMQP::Transport.new(exchange, queue, :foo => :bar)
    end
    
    describe "write(buffer)" do
      it "should publish messages to the exchange" do
        exchange.should_receive(:publish).
          with("some message (encoded by thrift)", :headers => {:foo => :bar}).
          once

        transport.write("some message (encoded by thrift)")
        transport.flush
      end
      it "should not publish on simple write" do
        exchange.should_receive(:publish).never

        transport.write("some message (encoded by thrift)")
      end 
      it "should publish on #flush" do
        exchange.should_receive(:publish).once

        transport.write("foo")
        transport.write("bar")
        transport.flush
      end 
    end
  end
end