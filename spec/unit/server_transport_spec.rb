require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp'

describe TOAMQP::ServerTransport do
  attr_reader :transport, :topology, :queue
  before(:each) do
    @queue = flexmock(:queue)
    @topology = flexmock(:topology)

    topology.should_receive(
      :queue => queue, 
      :destroy => nil).by_default
      
    queue.should_receive(
      :message_count => 0).by_default 
    
    @transport = TOAMQP::ServerTransport.new(topology)
  end
  
  describe "#eof?" do
    it "should be true" do
      transport.should be_eof
    end 
  end
  
  describe "#listen" do
    it "should allow calling" do
      transport.listen
    end
  end
  describe "#accept" do
    it "should block" do
      block_exception = Class.new(Exception)
      queue.should_receive(:subscribe).and_raise(block_exception)
      
      lambda {
        transport.accept
      }.should raise_error(block_exception)
    end
    context "return value when a message is posted" do
      before(:each) do
        queue.
          should_receive(:subscribe).and_yield(
            :payload => 'buffer'
          )
      end
      def call
        transport.accept
      end
      
      it "should be a TOAMQP::Transport" do
        call.should be_an_instance_of(TOAMQP::Transport)
      end
      it "should have a source" do
        call.source.should_not be_nil
      end
      it "should have a destination" do
        pending "bidirectional comm"
        call.destination.should_not be_nil
      end
    end
  end
  describe "#close" do
    it "should allow calling" do
      transport.close
    end 
  end
end