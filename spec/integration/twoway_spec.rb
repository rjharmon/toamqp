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
  include CustomMatchers
  
  attr_reader :service
  before(:each) do
    @service = connect_service('integration_spec_twoway', :twoway => true)
  end
  
  describe "public 'capitalize' service" do
    attr_reader :server, :client
    before(:each) do
      @server = SpecTestServer.new(service)
      @client = client_for(service)
    end
    after(:each) do
      server.close
    end
    
    context "when sent 'foo'" do
      attr_reader :result
      before(:each) do
        lambda {
          @result = client.capitalize('foo')
        }.should take_less_than(0.5).seconds
      end
      
      it "should return 'FOO'" do
        result.should == 'FOO'
      end 
    end
  end
end