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

    it "should create a client transport" do
      flexmock(connection).
        should_receive(:create_exchange_and_queue).and_return([nil, nil])
        
      connection.server_transport('chunky_bacon').
        should be_an_instance_of(Thrift::AMQP::ServerTransport)
    end
    it "should create a client transport" do
      flexmock(connection).
        should_receive(:create_exchange_and_queue).and_return([nil, nil])
        
      connection.client_transport('chunky_bacon').
        should be_an_instance_of(Thrift::AMQP::Transport)
    end
  end
end