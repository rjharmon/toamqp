
require 'bunny'

# Creates and holds connections to the AMQP server for the rest of the 
# classes. Please access this through the TOAMQP.spawn_connection factory
# method.
#
class TOAMQP::ConnectionManager
  # The connection attributes that will be used to connect to the AMQP server.
  #
  attr_accessor :connection_attributes
  
  def initialize
    # Default connection attributes
    @connection_attributes = {
      :host => 'localhost', 
      :vhost => '/',
      :user => 'guest', 
      :password => 'guest' }
  end
  
  # Spawns a new connection. This may return an old connection that isn't
  # used anymore - this is at the discretion of the manager. 
  #
  def spawn_connection
    connect
  end

  # Creates a new connection everytime you call it. This is internally used
  # by spawn_connection. 
  #
  def connect
    @connection = Bunny.new(connection_attributes)
    @connection.start
    
    # NOTE: This is a super undocumented feature that you will probably know
    # about only from reading AMQP specs. If we want to subscribe, but abort
    # subscription before all messages are read, we need to turn this on, otherwise
    # the server will go on and deliver all remaining messages in turn. See also
    # the :ack => true flag in ServerTransport...
    # 23Dez09, ksc
    @connection.qos

    @connection
  end
end

module TOAMQP
  class << self
    # Spawns a new connection to the AMQP server.
    #
    def spawn_connection
      connection_manager.spawn_connection
    end
    
    # Connection manager that is currently in use.
    #
    def connection_manager
      @connection_manager ||= TOAMQP::ConnectionManager.new
    end
    attr_writer :connection_manager
  end
end