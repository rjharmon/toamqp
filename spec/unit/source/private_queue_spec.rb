require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TOAMQP::Source::PrivateQueue do  
  attr_reader :exchange
  attr_reader :private_queue, :connection
  before(:each) do
    @exchange = flexmock(:exchange)
    @connection = flexmock(:connection)
    
    connection.should_receive(
      :exchange => exchange).by_default
  end

  context "when using a mocked queue" do
    attr_reader :queue
    before(:each) do
      @queue = flexmock(:queue, 
        :name => 'private', 
        :bind => nil)
      
      connection.should_receive(
        :queue => queue).by_default
    
      @private_queue = TOAMQP::Source::PrivateQueue.new(connection)
    end
    
    describe "#queue" do
      it "should return the anonymous queue" do
        private_queue.queue.should == queue
      end
    end
  end
  context "when using a stubbed queue (partial functionality)" do
    # Mocks a AMQP queue. Messages can be preloaded and are then just shifted
    # off an array.
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
      def pop
        if messages && msg=messages.shift
          return { :payload => msg }
        else
          return { :payload => :queue_empty }
        end
      end
      
      def name
        'queue_stub_private_queue_name'
      end
      def bind(*args)
      end
    end
    
    attr_reader :queue
    before(:each) do
      @queue = QueueStub.new
      
      connection.should_receive(
        :queue => queue)
    
      @private_queue = TOAMQP::Source::PrivateQueue.new(connection)
    end

    describe "#read" do
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
      end
      context "when queue is initially empty" do
        before(:each) do
          queue.messages = [:queue_empty, 'message']
        end

        it "should read 'message'" do
          private_queue.read(1000).should == 'message'
        end 
      end
    end
  end
end