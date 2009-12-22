
require 'thrift'

# Root module for the Thrift Over AMQP framework.
module TOAMQP; 
  module Service; end;
  module Target; end;
end

require 'toamqp/service/base'
require 'toamqp/connection_manager'