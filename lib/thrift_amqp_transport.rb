
require 'thrift'    # for messaging
require 'bunny'     # for AMQP interaction

module Thrift
  module AMQP
    VERSION = '0.1.0'

    # This gets thrown if the connection to the AMQP server fails. 
    #
    class ConnectionError < StandardError; end

    # Connects to a AMQP server. 
    #
    # Parameters: 
    # 
    #   +host+  :: host your AMQP server is running on
    #   +vhost+ :: virtual host to connect to 
    #   +user+  :: user to connect with
    #   +password+ :: password to use for the connection.
    #
    def start(credentials={})
      Connection.start(credentials)
    end
    module_function :start
  end
end

require 'thrift_amqp/endpoints'
require 'thrift_amqp/service'
require 'thrift_amqp/server_transport'
require 'thrift_amqp/transport'
require 'thrift_amqp/connection'