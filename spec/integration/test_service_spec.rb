require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

class SpecServer < Thrift::BaseServer
  def serve
    begin
      @server_transport.listen
      while not @server_transport.eof?
        client = @server_transport.accept
        trans = @transport_factory.get_transport(client)
        prot = @protocol_factory.get_protocol(trans)
        begin
          loop do
            @processor.process(prot, prot)
          end
        rescue Thrift::TransportException, Thrift::ProtocolException
        ensure
          trans.close
        end
      end
    ensure
      @server_transport.close
    end
  end
end

describe "Server of test service" do
  class TestService < TOAMQP::Service::Base
    serves Test
    exchange :test
    
    def announce(msg)
    end
    def add(a,b)
      a+b
    end
  end
  
  attr_reader :server, :client
  before(:each) do
    @server = TOAMQP.server(TestService.new, SpecServer)
    @client = TOAMQP.client('test', Test)
  end
  
  context "oneway #announce" do
    it "should transmit message" do
      client.announce('foo')
      server.serve

      received_messages.should include('foo')
    end
    it "should return without waiting for answer (asynchronous operation)" do
      pending 'simple case'
      client.announce('foo')
      client.announce('bar')

      # Since we didn't wait for the server, it didn't do the work.
      received_messages.should be_empty
    end
    context "server" do
      it "should receive the call" do
        flexmock(server).
          should_receive(:announce).once
        
        client.announce('foo')
      end 
    end
  end
  context "twoway #add" do
    context "call with (13, 29)" do
      def call
        client.add(13, 29)
      end

      it "should return 42" do
        pending 'simple case'
        call.should == 42
      end 
    end
  end    
end