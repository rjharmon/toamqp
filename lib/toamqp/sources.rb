
# All sources for a transport.
#
module TOAMQP::Source
  # Reading from a packet that has already arrived. 
  #
  class Packet
    def initialize(buffer)
      @io = StringIO.new(buffer)
    end
    
    def read(count)
      @io.read(count)
    end
  end
end