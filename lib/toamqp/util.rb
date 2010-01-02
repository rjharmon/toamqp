

# Utility functions that have no real place (or that would need to be
# stuffed in some base Ruby class).
#
module TOAMQP
  module Util
    def stringify_hash(h)
      h.inject({}) { |h,(k,v)|
        h[k.to_s] = v.to_s
        h }
    end
    
    module_function :stringify_hash
  end
end