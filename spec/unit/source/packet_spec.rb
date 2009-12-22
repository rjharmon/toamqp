require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TOAMQP::Source::Packet do
  attr_reader :packet, :buffer
  before(:each) do
    @buffer = (0..100).to_a.map { |charcode| ?a + (charcode%26) }.pack('c*')
    @packet = TOAMQP::Source::Packet.new(buffer)
  end
  
  describe "#read" do
    it "should allow reading small chunks of data" do
      packet.read(1).size.should == 1
    end 
    it "should allow reading bytewise" do
      buffer.each_char do |byte|
        packet.read(1).should == byte
      end
    end 
    it "should allow reading big chunks (returning the whole buffer)" do
      packet.read(1000).size.should == buffer.size
    end 
    it "should return the buffer" do
      packet.read(1000).should == buffer
    end 
  end
end