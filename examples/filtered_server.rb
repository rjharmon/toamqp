
require 'common'

$filter_for = ARGV.first
unless $filter_for
  puts "filtered_server.rb FILTERWORD"
  puts "Will only accept messages that have a header of filter: FILTERWORD."
  exit 1
end

class ExampleService < TOAMQP::Service::Base
  exchange :service, :match => { :filter => $filter_for }
  serves Test
  
  def add(a,b)
    p [:add, a, b]
    a+b
  end
  
  def announce(message)
    p [:announce, message]
  end
end


service = ExampleService.new

server = TOAMQP.server(ExampleService.new)
server.serve