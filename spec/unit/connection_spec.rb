require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thrift::AMQP::Connection do
  it "should allow connection to an existing host" do
    flexmock(Thrift::AMQP::Connection).new_instances.
      should_receive(:start).once

    Thrift::AMQP::Connection.start(
      :host => 'somehost', 
      :vhost => '/vhost', 
      :user => 'foo', 
      :password => 'bar'
    )
  end
  it "should fail construction when host does not exist" do
    flexmock(Thrift::AMQP::Connection).new_instances.
      should_receive(:start).and_raise(Thrift::AMQP::ConnectionError)
    
    lambda {
      Thrift::AMQP::Connection.start
    }.should raise_error(Thrift::AMQP::ConnectionError)
  end
  
  context 'partially mocked' do
    attr_reader :connection
    before(:each) do
      @connection = Thrift::AMQP::Connection.new(
        :host => 'somehost', 
        :vhost => '/vhost', 
        :user => 'foo', 
        :password => 'bar'
      )
      
      flexmock(connection).
        should_receive(:_create_exchange).and_return(nil).
        should_receive(:_create_queue).and_return(nil)
    end

    describe "#start" do
      it "should create a bunny instance, passing the right arguments" do
        flexmock(Bunny).should_receive(:new).with(
          :host => 'somehost', 
          :vhost => '/vhost', 
          :user => 'foo', 
          :pass => 'bar'
          ).once.
          and_return(flexmock(:start => nil))
        
        connection.start
      end 
    end

    it "should create a server transport" do
      connection.server_transport('chunky_bacon').
        should be_an_instance_of(Thrift::AMQP::ServerTransport)
    end
    describe "#client_transport" do
      attr_reader :transport
      before(:each) do
        @transport = connection.client_transport('chunky_bacon', :foo => :bar)
      end
      
      it "should be an instance of Thrift::AMQP::Transport" do
        transport.should be_an_instance_of(Thrift::AMQP::Transport)
      end
      it "should contain a correct set of headers" do
        transport.headers['foo'].should == 'bar'
      end
    end

    describe "#stringify" do
      attr_reader :result
      before(:each) do
        @result = connection.stringify(
          :foo => :bar)
      end
      
      it "should convert keys" do
        result.keys.should include('foo')
      end
      it "should convert values" do
        result.values.should include('bar')
      end
    end
    describe "#queue_name(exchange)" do
      attr_reader :result
      before(:each) do
        @result = connection.queue_name('EXCHANGE')
      end
      
      it "should be of the form EXCHANGE-UUID" do
        result.should match(/EXCHANGE-[a-f0-9-]+/)
      end 
    end
  end
end