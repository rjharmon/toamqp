require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'pp'
require 'toamqp'

unless defined?(PROJECT_BASE)
  PROJECT_BASE = File.join(File.dirname(__FILE__), '..')
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end