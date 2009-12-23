
require 'common'

announcer = TOAMQP.client('service', Test)

msg = "Message from #{Time.now}"
puts "Announcing: #{msg}"

announcer.announce(msg)   # will return instantly, result is printed on the server