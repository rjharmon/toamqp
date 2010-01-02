
require 'common'

filter_for = ARGV.first
unless filter_for
  puts "filtered_announce.rb FILTERWORD"
  puts "Will send messages with the given FILTERWORD in the header. Only servers that listen for this FILTERWORD will receive the message."
  exit 1
end

announcer = TOAMQP.client('service', Test, 
  :header => {:filter => filter_for})

msg = "Message from #{Time.now}"
puts "Announcing: #{msg}"

announcer.announce(msg)   # will return instantly, result is printed on the server