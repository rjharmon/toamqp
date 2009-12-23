
require 'common'

class ExampleService < TOAMQP::Service::Base
  exchange :service
  serves Test
  
  def add(a,b)
    p [:add, a, b]
    a+b
  end
  
  def announce(message)
    p [:announce, message]
  end
end

server = TOAMQP.server(ExampleService.new)
server.serve