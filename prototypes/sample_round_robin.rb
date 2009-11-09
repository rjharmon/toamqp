# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

require 'rubygems'
require 'bunny'

b = Bunny.new

# start a communication session with the amqp server
b.start

# create a headers exchange
header_exch = b.exchange('round_robin', :type => :headers)

# declare queues
q = b.queue('round_robin')

# bind the queue to the exchange
q.bind(header_exch)

# publish messages to the exchange
header_exch.publish('Headers test msg 1', :headers => {'h1'=>'a'})
header_exch.publish('Headers test msg 2', :headers => {'h1'=>'z'})

# get messages from the queue - should only be msg 1 that got through
msg = ""
until msg == :queue_empty do
	msg = q.pop[:payload]
	puts 'This is a message from the header_q1 queue: ' + msg + "\n" unless msg == :queue_empty
end

# close the client connection
b.stop