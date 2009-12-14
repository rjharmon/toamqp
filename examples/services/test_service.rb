

class TestService < TOAMQP::Service::Base
  def announce(message)
    puts message
  end
  
  def add(a,b)
    a+b
  end
end