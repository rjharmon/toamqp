module CustomMatchers
  class IgnoreMessageAndReturn
    def initialize(return_value)
      @return_value = return_value
    end
    
    def method_missing(sym, *args, &block)
      @return_value
    end
  end
  
  # Example: 
  #
  #   lambda { sleep 1 }.should take_less_than(2).seconds
  #
  def take_less_than(secs)
    matcher = simple_matcher do |given, matcher|
      matcher.failure_message = "expected to take less than #{secs} seconds, but got a timeout"
      
      begin
        timeout(secs) do
          given.call
        end
        
        return true
      rescue Timeout::Error
        false
      end
    end
    
    IgnoreMessageAndReturn.new matcher
  end
end