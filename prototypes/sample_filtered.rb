# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

require 'rubygems'
require 'bunny'

b = Bunny.new

# start a communication session with the amqp server
b.start

# create a headers exchange
header_exch = b.exchange('filtered', :type => :headers)

# declare queues
q1 = b.queue('filtered_foo_bar')

# bind the queue to the exchange
q1.bind(header_exch, :arguments => {'foo'=>'bar','x-match'=>'all'})

# publish messages to the exchange
header_exch.publish('Headers test msg 1', :headers => {'foo' => 'bar'})
header_exch.publish('Headers test msg 2', :headers => {'foo' => 'baz'})

# get messages from the queue - should only be msg 1 that got through
msg = ""
until msg == :queue_empty do
	msg = q1.pop[:payload]
	puts 'This is a message from the header_q1 queue: ' + msg + "\n" unless msg == :queue_empty
end

# close the client connection
b.stop