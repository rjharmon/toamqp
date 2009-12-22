require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp'

describe TOAMQP::ServerTransport do
  attr_reader :transport
  before(:each) do
    @transport = TOAMQP::ServerTransport.new
  end
  
  describe "#listen" do
    it "should allow calling" do
      transport.listen
    end
  end
  describe "#accept" do
    it "should allow calling" do
      transport.accept
    end
    context "return value" do
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