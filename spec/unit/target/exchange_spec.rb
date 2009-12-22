require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'toamqp'
require 'toamqp'
require 'toamqp/target/exchange'

describe TOAMQP::Target::Exchange do
  attr_reader :target, :exchange
  before(:each) do
    @exchange = flexmock(:exchange)
    @target = TOAMQP::Target::Exchange.new(exchange)
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
    end
    it "should publish the buffered message to the exchange" do
      exchange.should_receive(:publish).with('some message').once
      
      target.flush
    end 
  end
end