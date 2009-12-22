# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{toamqp}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kaspar Schiess"]
  s.date = %q{2009-12-22}
  s.email = %q{kaspar.schiess@absurd.li}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["connection.yml", "connection.yml.template", "History.txt", "Manifest.txt", "Rakefile", "README.textile", "spec/integration", "spec/integration/protocol", "spec/integration/protocol/gen-rb", "spec/integration/protocol/gen-rb/test.rb", "spec/integration/protocol/gen-rb/test_constants.rb", "spec/integration/protocol/gen-rb/test_types.rb", "spec/integration/protocol/test.thrift", "spec/integration/test_client_spec.rb", "spec/integration/test_service_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit", "spec/unit/bridge_spec.rb", "spec/unit/client_spec.rb", "spec/unit/connection_manager_spec.rb", "spec/unit/server_transport_spec.rb", "spec/unit/service", "spec/unit/service/base_spec.rb", "spec/unit/service_spec.rb", "spec/unit/source", "spec/unit/source/packet_spec.rb", "spec/unit/target", "spec/unit/target/exchange_spec.rb", "spec/unit/toamqp_module_spec.rb", "spec/unit/transport_spec.rb", "lib/thrift_amqp", "lib/thrift_amqp/connection.rb", "lib/thrift_amqp/endpoints.rb", "lib/thrift_amqp/server_transport.rb", "lib/thrift_amqp/service.rb", "lib/thrift_amqp/transport.rb", "lib/thrift_amqp_transport.rb", "lib/toamqp", "lib/toamqp/bridge.rb", "lib/toamqp/connection_manager.rb", "lib/toamqp/server_transport.rb", "lib/toamqp/service", "lib/toamqp/service/base.rb", "lib/toamqp/sources.rb", "lib/toamqp/target", "lib/toamqp/target/exchange.rb", "lib/toamqp/transport.rb", "lib/toamqp.rb"]
  s.homepage = %q{http://blog.absurd.li}
  s.rdoc_options = ["--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Allows thrift RPC via an AMQP broker}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bunny>, ["~> 0.6.0"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.0.2"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, [">= 0"])
    else
      s.add_dependency(%q<bunny>, ["~> 0.6.0"])
      s.add_dependency(%q<uuid>, ["~> 2.0.2"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<flexmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<bunny>, ["~> 0.6.0"])
    s.add_dependency(%q<uuid>, ["~> 2.0.2"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<flexmock>, [">= 0"])
  end
end
