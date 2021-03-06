require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TOAMQP::Topology do
  attr_reader :topology
  attr_reader :connection
  attr_reader :queue, :exchange
  before(:each) do
    @connection = flexmock(:connnection)
    
    @queue = flexmock(:queue)
    @exchange = flexmock(:exchange)
    
    connection.should_receive(
      :queue => queue, 
      :exchange => exchange).by_default
      
    queue.should_receive(
      :bind => nil).by_default
    
    @topology = TOAMQP::Topology.new(connection, 'exchange_name')
  end

  describe "#produce_queue_name" do
    it "should accept symbols in :match option (regression)" do
      TOAMQP::Topology.new(connection, 'exchange_name', 
        :match => {:foo => :bar, :something => :other}).
        produce_queue_name('test').should == "test-foo_bar-something_other"
    end 
  end
  describe "#exchange" do
    context "if the creation of the exchange fails" do
      it "should raise a TOAMQP::CantCreateExchange exception" do
        connection.should_receive(:exchange).and_raise(Bunny::ForcedConnectionCloseError)
        
        lambda {
          topology.exchange
        }.should raise_error(TOAMQP::CantCreateExchange)
      end 
    end
  end
  describe "#queue" do
    it "should return a queue" do
      topology.queue.should == queue
    end
    it "should be named the same as the service" do
      connection.should_receive(:queue).with('exchange_name').once.
        and_return(queue)
      
      topology.queue
    end 
  end
  describe "#destroy" do
    it "should close the connection" do
      connection.should_receive(:close).once
      
      topology.destroy
    end 
  end

  context "constructed with :match" do
    before(:each) do
      @topology = TOAMQP::Topology.new(connection, 'exchange_name', 
        :match => {:foo => :bar})
    end
    it "should construct exchange to be of :headers type" do
      connection.should_receive(:exchange).
        with('exchange_name', :type => :headers).and_return(exchange).
        once

      topology.queue
    end 
    it "should bind to the exchange using header match arguments" do
      queue.should_receive(:bind).
        with(exchange, :arguments => {'x-match' => 'all', 'foo' => 'bar'}).
        once
      
      topology.queue
    end 
  end
end
