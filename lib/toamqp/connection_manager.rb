
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
    unless @connection
      @connection = Bunny.new(connection_attributes)
      
      @connection.start
    end
    
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