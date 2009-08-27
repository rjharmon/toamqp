require 'hoe'
 
namespace :hoe do # Too much out of the box... 
  Hoe.spec 'thrift_amqp_transport' do 
    developer('Kaspar Schiess', 'eule@space.ch')
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


compile_integration = file 'spec/integration/gen-rb/test.rb' => %w(spec/integration/test.thrift) do
  rm_rf 'spec/integration/gen-rb' rescue nil
  sh %Q{thrift --gen rb -o spec/integration spec/integration/test.thrift }
end

desc "Compiles thrift IDL definitions into Ruby code."
task :thrift => compile_integration

task :default => 'spec:all'