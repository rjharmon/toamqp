require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'toamqp'

describe TOAMQP::Target::Generic do
  attr_reader :target, :exchange
  before(:each) do
    @exchange = flexmock(:exchange)
    
    exchange.should_ignore_missing
    
    @target = TOAMQP::Target::Generic.new(exchange)
  end
  
  describe "#write(buffer)" do
    it "should allow writing to" do
      target.write('test')
    end 
  end
  describe "#flush" do
    it "should allow flushing" do
      target.flush
    end
    context "after buffering 'some message'" do
      before(:each) do
        target.write 'some'
        target.write ' '
        target.write 'message'
      end

      it "should publish the buffered message to the exchange" do
        exchange.should_receive(:publish).with('some message', Hash).once

        target.flush
      end 
      it "should have an empty buffer after flush" do
        target.flush
        target.buffer.should be_empty
      end 
    end
  end
end