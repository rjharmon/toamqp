require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TOAMQP::Util do
  include TOAMQP::Util
  
  describe "#stringify_hash" do
    attr_reader :result
    before(:each) do
      @result = stringify_hash :foo => :bar
    end
    
    it "should have string key 'foo'" do
      result.keys.should include('foo')
    end 
    it "should have string value 'bar'" do
      result['foo'].should == 'bar'
    end
  end
end