
require 'common'

adder = TOAMQP.client('service', Test)

puts "Adding 13 and 29"
result = adder.add(13, 29)

puts "Result: #{result}"