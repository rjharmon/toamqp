require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TOAMQP::ConnectionManager do
  context "instance" do
    attr_reader :instance
    before(:each) do
      @instance = TOAMQP::ConnectionManager.new
    end
    
    it "should have default connection attributes" do
      instance.connection_attributes.should == {
        :host => 'localhost', 
        :vhost => '/',
        :user => 'guest', 
        :password => 'guest'
      }
    end 
    
    describe "#spawn_connection" do
      context "return value" do
        def value
          instance.spawn_connection
        end

        it "should return a bunny connection" do
          value.should be_an_instance_of(Bunny::Client)
        end
        it "should be connected" do
          value.status.should == :connected
        end 
      end
    end
  end
end