require 'hoe'
 
namespace :hoe do # Too much out of the box... 
  Hoe.spec 'thrift_amqp_transport' do 
    developer('Kaspar Schiess', 'eule@space.ch')
    
    extra_deps << ['bunny', '>=0.6.0']
    extra_deps << ['uuid', '>=2.0.2']
    
    # For trivial reasons...
    extra_dev_deps << ['activesupport', '>=2.3.3']
  end
end

desc "Runs all unit examples."
Spec::Rake::SpecTask.new('spec:unit') do |t|
  t.spec_files = FileList['spec/unit/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

desc "Runs all integration examples."
Spec::Rake::SpecTask.new('spec:integration') do |t|
  t.spec_files = FileList['spec/integration/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

desc "Runs all examples."
Spec::Rake::SpecTask.new('spec:all') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end


compile_integration = file 'spec/support/gen-rb/test.rb' => %w(spec/support/test.thrift) do
  rm_rf 'spec/support/gen-rb' rescue nil
  sh %Q{thrift --gen rb -o spec/support spec/support  /test.thrift }
end

desc "Compiles thrift IDL definitions into Ruby code."
task :thrift => compile_integration

task :default => 'spec:all'