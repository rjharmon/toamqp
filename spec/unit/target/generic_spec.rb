require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'toamqp'

describe TOAMQP::Target::Generic do
  attr_reader :target, :exchange
  before(:each) do
    @exchange = flexmock(:exchange)
    
    exchange.should_ignore_missing
    
    @target = TOAMQP::Target::Generic.new(exchange, 
      :headers => { :foo => :bar }, 
      :key => 'thekey')
  end
  
  describe "#key" do
    it "should store the key option" do
      target.key.should == 'thekey'
    end 
  end
  describe "#headers" do
    it "should have stringified the keys" do
      target.headers.keys.should include('foo')
    end 
    it "should have stringified the values" do
      target.headers.values.should include('bar')
    end 
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
        publish_options = {
          :headers => { 'foo' => 'bar' }, 
          :key     => 'thekey'
        }
        exchange.should_receive(:publish).with('some message', publish_options).once

        target.flush
      end 
      it "should have an empty buffer after flush" do
        target.flush
        target.buffer.should be_empty
      end 
    end
  end
end