require 'metaid'

class TOAMQP::Service::Base
  
  # Creates queues and exchanges and links things up
  #
  attr_reader :topology
  
  # Returns a constant from the thrift module that was specified in the 
  # class.
  #
  def thrift_module_constant(constant)
    self.class.thrift_module.const_get(constant)
  end

  # Returns a thrift processor for this service. 
  #
  def thrift_processor
    thrift_module_constant('Processor').new(self)
  end
  
  # Returns a server transport for this service.
  #
  def server_transport
    TOAMQP::ServerTransport.new(self.class.topology)
  end
  
  class << self # CLASS METHODS
    def exchange(name, opts={})
      @exchange_name = name
      @topology_options = opts
    end
    
    # Tells the user that he should use
    #
    #   serves THRIFT_MODULE
    #
    # in his service class.
    #
    def thrift_module
      raise "No thrift module defined. Did you include 'serves THRIFT_MODULE'?"
    end
    
    def serves(thrift_module)
      # Thanks, _why!
      meta_def :thrift_module do
        thrift_module
      end
    end
    
    # Uses the configuration you've stored in this class to produce a 
    # network topology.
    #
    def topology
      connection = TOAMQP.spawn_connection

      TOAMQP::Topology.new(
        connection, 
        @exchange_name, 
        @topology_options || {})
    end
  end
end