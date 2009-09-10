
require 'thrift'    # for messaging
require 'bunny'     # for AMQP interaction

module Thrift
  module AMQP
    VERSION = '0.1.0'

    # This gets thrown if the connection to the AMQP server fails. 
    #
    class ConnectionError < StandardError; end
  end
end

require 'thrift_amqp/server_transport'
require 'thrift_amqp/transport'
require 'thrift_amqp/connection'