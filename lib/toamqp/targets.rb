

# All targets for a transport.
#
module TOAMQP::Target
  # Writes to an exchange or queue.
  #
  class Generic  
    attr_reader :buffer, :headers, :key
    
    # Initializes a target that publishes to a queue or to an exchange. 
    #
    def initialize(exchange, options={})
      @exchange = exchange
      @buffer = String.new
      
      @headers  = TOAMQP::Util.stringify_hash(options[:headers] || {})
      @key      = options[:key]
    end

    def write(buffer)
      @buffer << buffer
    end

    def flush
      # require 'pp'
      # pp [:flush, @buffer, headers]            
      
      options = {}
      
      options[:key] = key.to_s        if key
      options[:headers] = headers     if headers

      @exchange.publish @buffer, options

      @buffer = ''
    end
  end
end