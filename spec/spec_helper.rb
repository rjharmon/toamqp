require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'thrift_amqp_transport'

unless defined?(PROJECT_BASE)
  PROJECT_BASE = File.join(File.dirname(__FILE__), '..')
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
  
  # This makes the debug output hack work. We might expand this in the future
  # to also print the location where the debug output has been produced. 
  #
  config.after(:all) do
    $stdout.flush
  end
end

def set_defaults(mock, hash)
  hash.each do |k, v|
    mock.should_receive(k).and_return(v).by_default
  end
end

require 'pp'
class EscapedOut < StringIO
  def initialize(old_io)
    super()
    @old_io = old_io
  end
  def flush
    @old_io.write "<pre>" + string.
      gsub(/</, '&lt;').
      gsub(/\n/, '<br/>') + "</pre>"

    truncate 0
  end
end
$stdout = EscapedOut.new($stdout)