
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
      raise Thrift::TransportException if @io.eof?
      @io.read(count)
    end
  end
end