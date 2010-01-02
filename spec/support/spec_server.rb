
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
      
      # Wait for messages to arrive at the queue
      if @server_transport.eof?
        sleep 0.01
      end
      
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
    end
  end
  
  def close
    @server_transport.close
  end
  
  def serve_in_thread
    @stop_requested = false
    @stopped_cv = ConditionVariable.new
    @stopped_mx = Mutex.new
    
    thread = Thread.start do
      while !@stop_requested
        serve
      end
      
      @stopped_mx.synchronize do
        @stopped_cv.signal
      end
    end
    thread.abort_on_exception = true
  end
  
  def stop_and_join
    @stop_requested = true
    
    @stopped_mx.synchronize do
      @stopped_cv.wait(@stopped_mx)
    end
  end
end