require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thrift::AMQP::Connection do
  it "should allow connection to an existing host" do
    Thrift::AMQP::Connection.start(
      :host => 'somehost', 
      :vhost => '/vhost', 
      :user => 'foo', 
      :password => 'bar'
    )
  end
  it "should fail construction when host does not exist" do
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

      set_defaults(flexmock(connection), 
        :start_connection => nil)
    end

    it "should create a client transport" do
      connection.server_transport('chunky_bacon').
        should be_an_instance_of(Thrift::AMQP::ServerTransport)
    end
    it "should create a client transport" do
      connection.client_transport('chunky_bacon').
        should be_an_instance_of(Thrift::AMQP::Transport)
    end
  end
end