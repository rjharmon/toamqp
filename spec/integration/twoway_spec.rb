# service = Service.new('twoway', :twoway => true)
# 
# server_ep = service.endpoint()
# 
# server_ep.queue_name # => 'twoway'
# 
# client_transport = service.transport  # will connect client to twoway_client_UUID as well
# server_transport = server_ep.transport

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'support/spec_test_server'

describe "AMQP Transport Integration (twoway)" do
  include AMQPHelpers
  
  EXCHANGE_NAME = 'integration_spec_twoway'
  attr_reader :connection
  before(:each) do
    @connection = connect_for_integration_test
  end
  
  describe "public 'capitalize' service" do
    attr_reader :server
    before(:each) do
      @server = SpecTestServer.new(connection)
      @client = client_for()
    end
    
    context "when sent 'foo'" do
      attr_reader :result
      before(:each) do
        @result = client.capitalize('foo')
      end
      
      it "should return 'FOO'" do
        result.should == 'FOO'
      end 
    end
  end
end