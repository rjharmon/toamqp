require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

describe "Forked client with a test server" do
  class ForkedTestService < TOAMQP::Service::Base
    serves Test
    exchange :test_forked
    
    def add(a,b)
      a+b
    end
  end
  
  it "should add correctly" do
    begin
      @child_pid = fork do
        server = TOAMQP.server(ForkedTestService.new)
        server.serve
      end
      
      client = TOAMQP.client(:test_forked, Test)

      timeout(10) do # Timeout error means that communication didn't work
        client.add(1,2).should == 3
      end
    ensure
      Process.kill('KILL', @child_pid) rescue nil
    end
    
    Process.waitall
  end 
end