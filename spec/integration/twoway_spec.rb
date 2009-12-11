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
  
  describe "public 'capitalize' service" do
    attr_reader :server, :client
    before(:each) do
      # Client and server both need their own service, since we're going 
      # to use threading. 
      @server = SpecTestServer.new(connect_service('integration_spec_twoway', :twoway => true))
      @client = client_for(connect_service('integration_spec_twoway', :twoway => true))
    end
    after(:each) do
      server.close
    end
    
    context "when sent 'foo'" do
      attr_reader :result, :exceptions
      before(:each) do
        # Make sure that the spinner thread gets stopped. 
        @spinner_stop_mutex = Mutex.new
        @spinner_stop_cv    = ConditionVariable.new
        @spinner_stop_requested = false
        @exceptions = []
        
        @spinner_thread = Thread.start do
          while not @spinner_stop_requested
            begin
              server.spin
            rescue => exception
              p [:spinner_ex, exception]
              pp [:spinner_ex, exception.backtrace.first(5)]
              @exceptions << exception
            end
          end
          
          @spinner_stop_mutex.synchronize do
            @spinner_stop_cv.signal
          end
        end.abort_on_exception=true
        
        # Call the client (server will run in thread)
        lambda {
          @result = client.capitalize('foo')
        }.should take_less_than(1).seconds
      end
      after(:each) do
        @spinner_stop_requested = true
        
        @spinner_stop_mutex.synchronize do
          @spinner_stop_cv.wait @spinner_stop_mutex
        end
      end
      
      xit "should not collect any exceptions" do
        pending "get the other to work first"
        exceptions.should be_empty
      end 
      it "should return 'Foo'" do
        result.should == 'Foo'
      end 
    end
  end
end