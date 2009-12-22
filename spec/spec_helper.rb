require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'pp'
require 'toamqp'

unless defined?(PROJECT_BASE)
  PROJECT_BASE = File.join(File.dirname(__FILE__), '..')
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
  
  config.after(:each) do
    $stdout.flush
  end
end

# This should really be in TM...
class EscapedOut < StringIO
  def initialize(old_io)
    super()
    @old_io = old_io
  end
  def flush
    if string.size > 0
      @old_io.write "<pre>" + string.
        gsub(/</, '&lt;').
        gsub(/\n/, '<br/>') + "</pre>"
    end

    truncate 0
  end
end
$stdout = EscapedOut.new($stdout)