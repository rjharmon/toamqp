(in /Users/kaspar/git/own/thrift_amqp_transport)
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thrift_amqp_transport}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kaspar Schiess"]
  s.date = %q{2009-09-10}
  s.description = %q{Transports thrift messages over a the advanced message queue protocol. (AMQP)
Because of the unconnected broadcasting nature of the message queue, this 
transport supports only one-way communication. 

The usage scenario is that you would use this to broadcast information about 
services (1 producer, n consumers) and then create point to point connections 
from client to service using normal (TCP) thrift. You gain the advantage of
using only one interface definition language (IDL).}
  s.email = ["eule@space.ch"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "connection.yml.template", "lib/thrift_amqp/connection.rb", "lib/thrift_amqp/server_transport.rb", "lib/thrift_amqp/transport.rb", "lib/thrift_amqp_transport.rb", "spec/integration/oneway_spec.rb", "spec/integration/test.thrift", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/connection_spec.rb", "spec/unit/server_transport_spec.rb", "spec/unit/transport_spec.rb"]
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{thrift_amqp_transport}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Transports thrift messages over a the advanced message queue protocol}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bunny>, [">= 0.5.2"])
      s.add_development_dependency(%q<activesupport>, [">= 2.3.3"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<bunny>, [">= 0.5.2"])
      s.add_dependency(%q<activesupport>, [">= 2.3.3"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<bunny>, [">= 0.5.2"])
    s.add_dependency(%q<activesupport>, [">= 2.3.3"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
