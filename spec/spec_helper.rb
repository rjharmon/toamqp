require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/../generated/gen-rb'

unless defined?(PROJECT_BASE)
  PROJECT_BASE = File.join(File.dirname(__FILE__), '..')
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end