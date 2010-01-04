

# Creates queues and exchanges and the connections between them, based on 
# what the user specifies.
class TOAMQP::Topology
  # The connection that underlies this topology.
  #
  attr_reader :connection
  
  # Name of the exchange this service is bound to.
  #
  attr_reader :exchange_name
  
  # Options that were passed to the constructor
  #
  attr_reader :options
  
  # Creates a new queue/exchange topology. 
  #
  def initialize(connection, exchange_name, options={})
    @connection = connection
    @exchange_name = exchange_name.to_s
    @options = options
  end
  
  # Returns the queue the server listens to. 
  #
  def queue
    @queue ||= produce_queue
  end
  
  # Returns the exchange that requests are posted to.
  #
  def exchange
    @exchange ||= produce_exchange
  end
  
  def produce_exchange
    exchange_type = match_headers? ? :headers : :direct
    connection.exchange(exchange_name, :type => exchange_type)
    
  rescue Bunny::ForcedChannelCloseError, Bunny::ForcedConnectionCloseError
    raise TOAMQP::CantCreateExchange, 
      "Maybe exchange '#{exchange_name}' already exists and is of a different type than #{exchange_type.inspect} ?"
  end
  def produce_queue
    queue = connection.queue(
      produce_queue_name(exchange_name))
    
    bind_options = {}
    if match_headers?
      bind_options[:arguments] = {'x-match' => 'all'}.merge(
        TOAMQP::Util.stringify_hash(options[:match]))
    end
    
    queue.bind(exchange, bind_options)
    
    return queue
  end
  def produce_queue_name(exchange_name)
    if match_headers?
      # Queue names are derived from the filter attributes. We sort the keys
      # and compose the name from the exchange and the filter.
      match_header = options[:match]
      [
        exchange_name,
        match_header.keys.sort.map { |k| "#{k}_#{match_header[k]}" }].
        flatten.join('-')
    else
      exchange_name
    end
  end
    
  # Closes the connection and cleans up after the topology. 
  #
  def destroy
    connection.close
  end
  
  # True if we match headers when receiving messages
  #
  def match_headers?
    options.has_key? :match
  end
end