

# All targets for a transport.
#
module TOAMQP::Target
  # Writes to an exchange.
  #
  class Generic  
    attr_reader :buffer
    
    # Initializes a target that publishes to a queue or to an exchange. 
    # Valid options include: 
    #
    #   :reply_to     queue to send replies to (will be sent in headers)
    #
    def initialize(exchange, options={})
      @exchange = exchange
      @buffer = String.new
      
      @reply_to_queue = options[:reply_to]
    end

    def write(buffer)
      @buffer << buffer
    end

    def flush
      headers = {}

      # TODO: Make this comply to the SOA recommendation (23Dez09, ksc)
      headers['reply_to'] = @reply_to_queue if @reply_to_queue
            
      # require 'pp'
      # pp [:flush, @buffer, headers]            
      @exchange.publish @buffer, 
        :headers => headers

      @buffer = ''
    end
  end
end