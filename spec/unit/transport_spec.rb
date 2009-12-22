require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp/transport'

describe TOAMQP::Transport do
  attr_reader :transport
  before(:each) do
    destination = flexmock(:destination)
    destination.should_ignore_missing
    
    @transport = TOAMQP::Transport.new(
      :destination => destination)
  end
  
  describe "#write" do
    it "should accept a buffer" do
      transport.write('buffer')
    end 
    it "should delegate writes to the destination" do
      transport.destination.
        should_receive(:write).once
        
      transport.write('test')
    end 
  end
  describe "#flush" do
    it "should allow a flush to be called" do
      transport.flush
    end 
    it "should delegate flush to the destination" do
      transport.destination.
        should_receive(:flush).once
        
      transport.flush
    end 
  end
end