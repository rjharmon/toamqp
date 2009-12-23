

%w{/protocol/gen-rb /../lib}.each do |path|
  $:.unshift File.dirname(__FILE__) + path
end

# The library
require 'toamqp'

# Thrift generated code
require 'test'