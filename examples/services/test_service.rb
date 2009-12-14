
class TestSomethingService < TOAMQP::Service::Base
  # # A 
  # has_private_queue
  # exchange "test"
  # 
  # # B 
  # has_public_queue
  # exchange "test"
  # 
  # # C 
  # has_filtered_queue :foo => :bar
  # exchange "test"
  # 
  # # D 
  # has_private_queue
  # # No binding, since its private
  
  exchange 'test'
  
  def announce(message)
    puts "#announce: #{message}"
  end
  
  def add(a,b)
    puts "#add: #{a}, #{b}"
    a+b
  end
end
