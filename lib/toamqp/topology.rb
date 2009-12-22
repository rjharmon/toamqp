

# Creates queues and exchanges and the connections between them, based on 
# what the user specifies.
class TOAMQP::Topology
  
  # The connection that underlies this topology.
  #
  attr_reader :connection
  
  # Name of the exchange this service is bound to.
  #
  attr_reader :exchange_name
  
  # Creates a new queue/exchange topology. 
  #
  def initialize(connection, exchange_name)
    @connection = connection
    @exchange_name = exchange_name.to_s
  end
  
  # Returns the queue the server listens to. 
  #
  def queue
    @queue ||= produce_queue
  end
  
  # Returns the exchange that belongs to the service topology. 
  #
  def exchange
    @exchange ||= produce_exchange
  end
  
  def produce_exchange
    connection.exchange(exchange_name)
  end
  def produce_queue
    queue = connection.queue(exchange_name, 
      :exclusive => false)
    
    queue.bind(exchange)
    
    return queue
  end
  
  # Closes the connection and cleans up after the topology. 
  #
  def destroy
    connection.close
  end
end