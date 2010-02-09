require 'forwardable'

# A thrift transport that transports from +source+ to +destination+. Source
# and destination can be swapped out and are only delegated to. This way, 
# they need to only implement half of the Transport interface. 
#
# Compatible classes for +source+ are in sources.rb, targets.rb contains 
# all +destination+.
#
class TOAMQP::Transport < Thrift::BaseTransport
  extend Forwardable
  
  attr_reader :destination
  attr_reader :source
  
  # Initializes an AMQP transport. 
  #
  # Use the following options: 
  #
  #   :destination    where to send messages to, implements target
  #
  def initialize(options={})
    @destination = options[:destination]
    @source = options[:source]
  end

  # Destination interface
  def_delegators :destination, 
    :write, :flush
    
  # Source interface
  def_delegators :source, 
    :read
  
  # Closes the transport and its resources
  #
  def close
  end
end