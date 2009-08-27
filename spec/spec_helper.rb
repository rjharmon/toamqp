require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'thrift_amqp_transport'

unless defined?(PROJECT_BASE)
  PROJECT_BASE = File.join(File.dirname(__FILE__), '..')
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

def set_defaults(mock, hash)
  hash.each do |k, v|
    mock.should_receive(k).and_return(v).by_default
  end
end