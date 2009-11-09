

# Server transport for using oneway thrift over an AMQP-queue. 
#
# see Thrift::AMQP::Connection for more documentation.
#
class Thrift::AMQP::ServerTransport < Thrift::BaseServerTransport
  # Initializes a connection to the AMQP queue. If you provide a headers 
  # argument, only messages that match ALL headers will be accepted. 
  #
  def initialize(exchange, queue)
    @exchange = exchange
    @queue = queue
  end
  
  # Part of the server 
  def listen
    @transport = Thrift::AMQP::Transport.new(@exchange, @queue)
  end

  def accept
    @transport
  end
  
  def close
    # NOTE: We're not currently deleting the queues here, since having
    # guessable queue names will allow multiple processes to have references
    # to well known queues. In the future, queues should be deleted through
    # the endpoint interface. (ksc, 9Nov09)
    #
    # @queue.delete
  end
  
  # Returns true if there are messages waiting to be processed.
  #
  def waiting?
    @queue.message_count > 0
  end
end