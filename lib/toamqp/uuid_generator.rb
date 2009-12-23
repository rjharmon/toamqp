
require 'uuid'

module TOAMQP
  class << self
    def uuid_generator
      @uuid_generator ||= UUID.new
    end
  end
end