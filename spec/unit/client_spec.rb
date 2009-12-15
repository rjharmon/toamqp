require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'toamqp/client'

describe TOAMQP::Client do
  module ThriftModule
    class Client
      def initialize(protocol); end
    end
  end
  
  describe "#initialize" do
    def call
      TOAMQP::Client.new('test', ThriftModule)
    end
    
    it "should obtain a connection from TOAMQP" do
      flexmock(TOAMQP). 
        should_receive(:spawn_connection).once
        
      call
    end 
    it "should return a thrift client proxy" do
      call.should be_an_instance_of(ThriftModule::Client)
    end 
  end
end