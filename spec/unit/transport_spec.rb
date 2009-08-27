require File.dirname(__FILE__) + '/../spec_helper'

describe Thrift::AMQP::Transport, 'when constructed with an exchange (server)' do
  attr_reader :transport, :connection, :exchange, :queue
  before(:each) do
    @connection = flexmock(:connection)
    @exchange = flexmock(:exchange)
    @queue = flexmock(:queue)
    
    # Stub an interface for the connection 
    set_defaults(connection, 
      :queue => queue
    )
    
    set_defaults(exchange, 
      :name => 'exchange'
    )
    
    # Stub an interface for the queue
    set_defaults(queue, 
      :bind => nil, 
      :pop  => :queue_empty
    )
    
    @transport = Thrift::AMQP::Transport.new(connection, exchange)
  end
  
  describe "#read(sz)" do
    it "should poll for a new message on the queue" do
      queue.should_receive(:pop).and_return(:queue_empty,:queue_empty,'message')
      
      transport.read(1).should == 'm'
    end
    it "should return sz bytes" do
      queue.should_receive(:pop).and_return(' '*1000)
      
      transport.read(999).size.should == 999
      transport.read(10).size.should == 1
    end
    it "should return at most the whole message" do
      queue.should_receive(:pop).and_return(' '*1000)
      
      transport.read(2000).size.should == 1000
    end
  end
end