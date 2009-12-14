
# Illustrates how to access a twoway service
adder = TOAMQP::Client.new('test', Test)

a,b,(*) = ARGV.map { |arg| arg.to_i }
puts "Adding #{a} and #{b}"
result = adder.add(a,b)
puts "Result: #{result}"