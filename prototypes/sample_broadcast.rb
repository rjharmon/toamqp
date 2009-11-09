# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

require 'rubygems'
require 'bunny'

b = Bunny.new

# start a communication session with the amqp server
b.start

# create a headers exchange
header_exch = b.exchange('broadcast', :type => :headers)

q1 = b.queue('broadcast-1')
q1.bind(header_exch)
q2 = b.queue('broadcast-2')
q2.bind(header_exch)

# publish messages to the exchange
header_exch.publish('Headers test msg 1')
header_exch.publish('Headers test msg 2')

def empty(name, queue)
  msg = ""
  until msg == :queue_empty do
  	msg = queue.pop[:payload]
  	puts "This is a message from the #{name} queue: " + msg + "\n" unless msg == :queue_empty
  end
end

empty "q1", q1
empty "q2", q2

# close the client connection
b.stop