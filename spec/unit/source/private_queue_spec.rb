require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TOAMQP::Source::PrivateQueue do
  # Mocks a AMQP queue that either blocks (raises WouldBlock) or returns 
  # a message received just as Bunny does. Flexmock doesn't support this
  # complex sequential behaviour, so this is a real class
  #
  class QueueStub
    class WouldBlock<Exception; end
    
    attr_accessor :messages
    def subscribe(*args)
      if messages && msg=messages.shift
        queue_msg = { :payload => msg }
        yield queue_msg
      else
        raise WouldBlock
      end
    end
  end
  
  attr_reader :queue
  attr_reader :private_queue, :connection
  before(:each) do
    @connection = flexmock(:connection)
    @queue = QueueStub.new
    
    connection.should_receive(
      :queue => queue).by_default
    
    @private_queue = TOAMQP::Source::PrivateQueue.new(connection)
  end

  describe "#queue" do
    it "should return the anonymous queue" do
      private_queue.queue.should == queue
    end
  end
  describe "#read" do
    it "should block on subscribe until a message arrives" do
      lambda {
        private_queue.read(1)
      }.should raise_error(QueueStub::WouldBlock)
    end
    context "when a message is posted" do
      before(:each) do
        queue.messages = %w(buffer)
      end
      
      it "should allow reading the message in tiny bits" do
        private_queue.read(1).should == 'b'
      end
      it "should allow reading too much" do
        private_queue.read(1000).should == 'buffer'
      end
      context "and it has been read completely" do
        before(:each) do
          private_queue.read(1000)
        end

        it "should block for a new message" do
          lambda {
            private_queue.read(1)
          }.should raise_error(QueueStub::WouldBlock)
        end
      end
    end
  end
end