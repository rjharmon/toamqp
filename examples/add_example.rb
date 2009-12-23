
require 'common'

adder = TOAMQP.client('adder', Test)

puts "Adding 13 and 29"
result = adder.add(13, 29)

puts "Result: #{result}"