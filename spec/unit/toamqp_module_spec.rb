
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TOAMQP do
  describe "#spawn_connection" do
    attr_reader :manager
    before(:each) do
      @manager = TOAMQP.connection_manager = flexmock(:manager)
    end
    
    it "should delegate the call to the connection manager" do
      manager.
        should_receive(:spawn_connection).once.
        and_return(:connection)
        
      TOAMQP.spawn_connection.should == :connection
    end 
  end
end