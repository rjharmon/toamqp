
# A small thrift server based loosely on the Thrift::SimpleServer. The 
# difference is that this servers #serve will return as soon as there are
# no messages left on the queue. This allows testing like this: 
#
#   ...               # Set up, post some messages to the queue
#   server.serve      # Work on the queued messages
#   ...               # Verify assumptions, etc...
#
class SpecServer < Thrift::BaseServer
  def serve
    begin
      @server_transport.listen
      while not @server_transport.eof?
        client = @server_transport.accept
        trans = @transport_factory.get_transport(client)
        prot = @protocol_factory.get_protocol(trans)
        begin
          loop do
            @processor.process(prot, prot)
          end
        rescue Thrift::TransportException, Thrift::ProtocolException => ex
        ensure
          trans.close
        end
      end
    rescue => bang
      raise bang
    else
      @server_transport.close
    end
  end
end