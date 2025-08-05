# Automate serpapi ruby gem end to end
#
# rake --task
#
# main targets:
#
# rake dependency # to install dependency
# rake oobt # pre
#

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require_relative 'lib/serpapi'

desc "run out of box testing using the local gem file pre-release"
task oobt: %i[check readme doc build install demo]

desc "execute all the steps except release"
task default: %i[check dependency version readme doc build test oobt]

desc "update README.md from the template"
task readme: ['README.md.erb'] do
  `erb -T '-' README.md.erb > README.md`
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/*/*.rb', 'README.md', 'LICENSE']
  t.options = ['--markup=markdown']
  t.stats_options = ['--list-undoc']
end

desc 'validate core client spec files'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = Dir.glob('spec/serpapi/client/*_spec.rb') + Dir.glob('spec/serpapi/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

desc 'validate all the examples (comprehensive set of tests)' 
RSpec::Core::RakeTask.new(:regression) do |t|
  t.pattern = Dir.glob('spec/serpapi/client/example/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

desc 'run benchmark tests'
RSpec::Core::RakeTask.new(:benchmark) do |t|
  t.pattern = Dir.glob('spec/serpapi/client/benchmark/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

RuboCop::RakeTask.new(:lint) do |t|
  t.options = ['--display-cop-names']
end

desc "format ruby code using rubocop"
task :format do
  sh('rubocop --auto-correct')
end

desc 'install project dependencies'
task :dependency do
  sh 'bundle install'
end

desc 'build serpapi library as a gem'
task :build do
  sh 'gem build serpapi'
end

desc 'install serpapi library locally from the .gem'
task :install do
  sh "gem install ./serpapi-#{SerpApi::VERSION}.gem"
end

desc 'run demo example'
task :demo do
  Dir.glob('demo/*.rb').each do |file|
    puts "running demo: #{file}"
    sh "ruby #{file}"
  end
end

desc 'release the gem to the public rubygems.org'
task release: [:oobt] do
  sh 'gem push `ls -t1 *.gem | head -1`'
  puts 'release public on: https://rubygems.org/gems/serpapi/versions'
end

# private
task :check do
  if ENV['SERPAPI_KEY']
    puts 'check: found $SERPAPI_KEY'
  else
    puts 'check: SERPAPI_KEY must be defined'
    exit 1
  end
end

desc 'print current version'
task :version do
  puts 'current version: ' + SerpApi::VERSION
end

desc 'create a tag'
task :tag do
  version = SerpApi::VERSION
  puts "create git tag #{version}"
  sh "git tag #{version}"
  puts "now publish the tag:\n$ git push origin #{version}"
end