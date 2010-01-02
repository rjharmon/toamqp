# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{toamqp}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kaspar Schiess"]
  s.date = %q{2010-01-02}
  s.email = %q{kaspar.schiess@absurd.li}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["connection.yml.template", "History.txt", "Rakefile", "README.textile", "spec/integration", "spec/integration/client_spec.rb", "spec/integration/filtered_spec.rb", "spec/integration/protocol", "spec/integration/protocol/gen-rb", "spec/integration/protocol/gen-rb/test.rb", "spec/integration/protocol/gen-rb/test_constants.rb", "spec/integration/protocol/gen-rb/test_types.rb", "spec/integration/protocol/test.thrift", "spec/integration/service_spec.rb", "spec/integration/with_fork_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/support", "spec/support/spec_server.rb", "spec/unit", "spec/unit/bridge_spec.rb", "spec/unit/client_spec.rb", "spec/unit/connection_manager_spec.rb", "spec/unit/server_transport_spec.rb", "spec/unit/service", "spec/unit/service/base_spec.rb", "spec/unit/service_spec.rb", "spec/unit/source", "spec/unit/source/packet_spec.rb", "spec/unit/source/private_queue_spec.rb", "spec/unit/target", "spec/unit/target/generic_spec.rb", "spec/unit/toamqp_module_spec.rb", "spec/unit/topology_spec.rb", "spec/unit/transport_spec.rb", "spec/unit/uuid_generator_spec.rb", "lib/toamqp", "lib/toamqp/bridge.rb", "lib/toamqp/connection_manager.rb", "lib/toamqp/server_transport.rb", "lib/toamqp/service", "lib/toamqp/service/base.rb", "lib/toamqp/sources.rb", "lib/toamqp/targets.rb", "lib/toamqp/topology.rb", "lib/toamqp/transport.rb", "lib/toamqp/uuid_generator.rb", "lib/toamqp.rb"]
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
