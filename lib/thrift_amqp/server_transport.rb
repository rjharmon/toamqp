

# Server transport for using oneway thrift over an AMQP-queue. 
#
class Thrift::AMQP::ServerTransport
  def initialize(exchange_name, headers={})
    @exchange_name = exchange_name
    @header_filter = transform_hash_to_string(headers)
  end
  
  def listen
    # Connect to RabbitMQ
    @connection = Bunny.new   # TODO connection settings
    @connection.start

    # Create an exchange called +exchange_name+. 
    @exchange = @connection.exchange(@exchange_name, :type => :headers)
  end

  def accept
  end  
  
  def close
    @connection.stop
  end

private
  def transform_hash_to_string(hash)
    hash.inject({}) do |new_hash, (k,v)|
      new_hash[k.to_s] = v.to_s

      new_hash
    end
  end
end