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
        def call
          instance.spawn_connection
        end

        it "should return a bunny connection" do
          call.should be_an_instance_of(Bunny::Client)
        end
        it "should be connected" do
          call.status.should == :connected
        end 
        it "should return a different value every time it is called (regression)" do
          # NOTE: If this fails, you are most probably not getting a failure 
          # on the assertion on the last line, but you get a weird AMQP queue
          # error. That is because spawn_connection doesn't in fact generate
          # a different connection every time and messages are either called 
          # twice or out of sequence on one single connection. (21Jan10, ksc)
          
          connections = []
          
          # Connect 10 times to the AMQP host, returning object_ids of the connections
          10.times do
            Thread.new do
              connection = call
              
              connections << connection.object_id.to_s(16)
              
              connection.close
            end.abort_on_exception = true
          end

          # Wait for all ten threads to finish
          timeout(1) do
            sleep 0.01 while connections.size < 10
          end
          
          # Test how many DIFFERENT connections there are.
          connections.uniq.should have(10).elements
        end 
      end
    end
  end
end