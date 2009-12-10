# service = Service.new('twoway', :twoway => true)
# 
# server_ep = service.endpoint()
# 
# server_ep.queue_name # => 'twoway'
# 
# client_transport = service.transport  # will connect client to twoway_client_UUID as well
# server_transport = server_ep.transport

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Twoway Messagning" do
  EXCHANGE_NAME = 'integration_spec_oneway'
  attr_reader :connection
  before(:each) do
    @connection = connect_for_integration_test
  end
  
  
end