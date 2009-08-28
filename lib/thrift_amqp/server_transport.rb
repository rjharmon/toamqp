

# Server transport for using oneway thrift over an AMQP-queue. 
#
class Thrift::AMQP::ServerTransport
  def initialize(exchange_name, headers={})
    @exchange_name = exchange_name
    @header_filter = transform_hash_to_string(headers)
  end
  
  def listen
    @transport = Thrift::AMQP::Transport.connect(@exchange_name)
  end

  def accept
    @transport
  end  
  
  def close
  end

private
  def transform_hash_to_string(hash)
    hash.inject({}) do |new_hash, (k,v)|
      new_hash[k.to_s] = v.to_s

      new_hash
    end
  end
end