require 'metaid'

class TOAMQP::Service::Base
  
  # Creates queues and exchanges and links things up
  #
  attr_reader :topology
  
  def initialize
    @topology = TOAMQP::Topology.new
  end

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
    TOAMQP::ServerTransport.new(server_queue)
  end
  
  # Returns the queue to read messages from (servers perspective).
  #
  def server_queue
    topology.queue
  end
  
  class << self # CLASS METHODS
    def exchange(name)
    end
    
    def serves(thrift_module)
      # Thanks, _why!
      meta_def :thrift_module do
        thrift_module
      end
    end
  end
end