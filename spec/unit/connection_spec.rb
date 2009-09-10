require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Thrift::AMQP::Connection do
  attr_reader :connection
  before(:each) do
    @connection = Thrift::AMQP::Connection.new(
      :host => 'somehost', 
      :vhost => '/vhost'
    )
  end
  it "should allow connection to an existing host" 
  it "should fail construction when host does not exist"
  it "should create a client transport" do
    connection.server_transport.
      should be_an_instance_of(Thrift::AMQP::ServerTransport)
  end
  it "should create a client transport" do
    connection.client_transport.
      should be_an_instance_of(Thrift::AMQP::Transport)
  end
end