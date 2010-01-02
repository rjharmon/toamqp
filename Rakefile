
require 'spec'
require "spec/rake/spectask"
 
desc "Runs all examples."
Spec::Rake::SpecTask.new('spec' => :thrift) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

# This compiles the various thrift files that tests use.
#
compile_integration = file 'spec/integration/protocol/gen-rb/test.rb' => %w(spec/integration/protocol/test.thrift) do
  rm_rf 'spec/integration/protocol/gen-rb' rescue nil
  sh %Q{thrift --gen rb -o spec/integration/protocol spec/integration/protocol/test.thrift }
end

desc "Compiles thrift IDL definitions into Ruby code."
task :thrift => compile_integration

require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

task :default => :spec

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|
  
  # Change these as appropriate
  s.name              = "toamqp"
  s.version           = "0.3.1"
  s.summary           = "Allows thrift RPC via an AMQP broker"
  s.author            = "Kaspar Schiess"
  s.email             = "kaspar.schiess@absurd.li"
  s.homepage          = "http://blog.absurd.li"
  s.description       = %Q{Transports thrift RPC calls via an AMQP broker.}

  s.has_rdoc          = false
  s.extra_rdoc_files  = %w(README.textile)
  s.rdoc_options      = %w(--main README.textile)

  # Add any extra files to include in the gem
  s.files             = %w(
    History.txt 
    Rakefile 
    README.textile ) + 
    Dir.glob("{spec,lib,examples}/**/*")
   
  s.require_paths     = ["lib"]
  
  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("bunny", "~> 0.6.0")
  s.add_dependency("uuid", "~> 2.0.2")
  s.add_dependency("metaid", "~> 1.0.0")
  
  s.add_development_dependency("rspec") 
  s.add_development_dependency("flexmock") 

  # If you want to publish automatically to rubyforge, you'll may need
  # to tweak this, and the publishing task below too.
  # s.rubyforge_project = "thrift_amqp_transport"
end

# This task actually builds the gem. We also regenerate a static 
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  
  # Generate the gemspec file for github.
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README.textile"
  rd.rdoc_files.include("README.textile", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

# End of Rake ----------------------------------------------------------------
