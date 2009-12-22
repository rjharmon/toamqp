require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift File.join(
  File.dirname(__FILE__), 'protocol/gen-rb')
require 'test'

require 'toamqp/client'

describe "Client" do
  attr_reader :client
  attr_reader :queue
  before(:each) do
    mq_conn = Bunny.new
    mq_conn.start
    
    @queue = mq_conn.queue('test')
    @client = TOAMQP::Client.new('test', Test)
  end
  after(:each) do
    # Pop off remaining messages
    while queue.message_count > 0
      queue.pop
    end

    queue.delete
  end
  
  context "after #announce has been posted to the queue" do
    before(:each) do
      client.announce('test')
    end
    
    it "should have one message waiting for the server" do
      queue.message_count.should > 0    # other tests may be running on the same queue
    end 
  end
end