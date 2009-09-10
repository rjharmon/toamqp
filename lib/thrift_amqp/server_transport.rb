

# Server transport for using oneway thrift over an AMQP-queue. 
#
# see Thrift::AMQP::Connection for more documentation.
#
class Thrift::AMQP::ServerTransport < Thrift::BaseServerTransport
  # Initializes a connection to the AMQP queue. If you provide a headers 
  # argument, only messages that match ALL headers will be accepted. 
  #
  # Example: 
  #
  #   Thrift::AMQP::ServerTransport.new('queue', :version => 1)
  #   # Will only match messages that have 'version' == '1'
  # 
  def initialize(exchange, queue)
    @exchange = exchange
    @queue    = queue
  end
  
  # Part of the server 
  def listen
    @transport = Thrift::AMQP::Transport.new(@exchange, @queue)
  end

  def accept
    @transport
  end
end