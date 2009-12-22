require 'forwardable'

class TOAMQP::Transport
  extend Forwardable
  
  attr_reader :destination
  
  # Initializes an AMQP transport. 
  #
  # Use the following options: 
  #
  #   :destination    where to send messages to, implements target
  #
  def initialize(options={})
    @destination = options[:destination]
  end

  def_delegators :destination, 
    :write, :flush
end