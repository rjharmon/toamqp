= Thrift AMQP transport

== DESCRIPTION

Transports thrift messages over a the advanced message queue protocol. (AMQP)
Because of the unconnected broadcasting nature of the message queue, this 
transport supports only one-way communication. 

The usage scenario is that you would use this to broadcast information about 
services (1 producer, n consumers) and then create point to point connections 
from client to service using normal (TCP) thrift. You gain the advantage of
using only one interface definition language (IDL). 

== SYNOPSIS

Using the following interface definition: 

  service AwesomeService {
    // a little hommage 
    oneway void battleCry(1:string battlecry);
  }
  
Create a connection to your AMQP server: 

  connection = Thrift::AMQP.start(
    :host => 'mq.mydomain.com
  )

On the server (consumer of messages): 

  class MyAwesomeHandler
    def battleCry(message)
      puts messages
    end
  end
  
  service = connection.service('battle_cry')
  handler = MyAwesomeHandler.new()
  processor = AwesomeService::Processor.new(handler)
  server_transport = service.endpoint.transport
  
  server = Thrift::SimpleServer.new(processor, transport)
  
  server.serve    # never returns

On the client: 

  service = connection.service('battle_cry')
  transport = service.transport
  protocol = Thrift::BinaryProtocol.new(transport)
  client = AwesomeService::Client.new(protocol)
  
  client.battleCry('chunky bacon!')   # prints 'chunky bacon!' on the server

== SPECIFICATION

To run the specs, just type

  rake specs
  
Integration tests need a AMQP-Server to run on localhost. This has so far only
been tested with RabbitMQ. (http://www.rabbitmq.com/) Alternatively, you may
specify the location of your AMQP-Server by filling in connection.yml in the
project's root.

  rake thrift
  rake integration
  
== REQUIREMENTS

rabbitmq-server: local server for integration tests
thrift: full installation needed if you want to compile service descriptions
bunny

Whatever server you choose must implement the headers exchange type. RabbitMQ
does so starting from version 1.6.0.

== LICENSE

(The MIT License)

Copyright (c) 2009 Kaspar Schiess

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

