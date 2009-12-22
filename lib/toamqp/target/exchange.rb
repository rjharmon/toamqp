
class TOAMQP::Target::Exchange  
  def initialize(exchange)
    @exchange = exchange
    @buffer = String.new
  end
  
  def write(buffer)
    @buffer << buffer
  end
  
  def flush
    @exchange.publish @buffer
  end
end