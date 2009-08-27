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
  t.warning = true
end

desc "Runs all examples."
Spec::Rake::SpecTask.new('spec:integration') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  t.warning = true
end

task :default => "spec:integration"