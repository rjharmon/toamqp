require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'UUID generator' do
  it "should return a generator" do
    TOAMQP.uuid_generator.should_not be_nil
  end
  it "should cache the generator" do
    TOAMQP.uuid_generator.should == TOAMQP.uuid_generator
  end
end