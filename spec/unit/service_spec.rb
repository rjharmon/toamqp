
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TOAMQP::Service::Base do
  context "a deriving class" do
    attr_reader :klass
    before(:each) do
      @klass = SpecService = Class.new(TOAMQP::Service::Base)
    end
    it "should define an exchange to use" do
      klass.instance_eval { exchange :test }
    end
  end
end