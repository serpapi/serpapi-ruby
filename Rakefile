require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require_relative 'lib/serpapi'

task :check do
  if ENV['API_KEY']
    puts 'check: found $API_KEY'
  else
    puts 'check: API_KEY must be defined'
    exit 1
  end
end

task readme: ['README.md.erb'] do
  `erb -T '-' README.md.erb > README.md`
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/*/*.rb', 'README.md', 'LICENSE']
  t.options = ['--markup=markdown']
  t.stats_options = ['--list-undoc']
end

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = Dir.glob('test/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

RuboCop::RakeTask.new(:lint) do |t|
  t.options = ['--display-cop-names']
end

task :dependency do
  sh 'bundle install'
end

task :build do
  sh 'gem build serpapi'
end

task :install do
  sh "gem install ./serpapi-#{SerpApi::VERSION}.gem"
end

task :demo do
  sh 'ruby oobt/demo.rb'
end

task :version do
  puts 'current version: ' + SerpApi::VERSION
end

task :tag do
  version = SerpApi::VERSION
  puts "create git tag #{version}"
  sh "git tag #{version}"
  puts "now publish the tag:\n$ git push origin #{version}"
end

task release: [:oobt] do
  sh 'gem push `ls -t1 *.gem | head -1`'
  puts 'release public on: https://rubygems.org/gems/serpapi/versions'
end

desc "run out of box testing using the gem file"
task oobt: %i[readme doc check build install demo]

desc "execute all the steps"
task default: %i[dependency version readme doc build test oobt]

desc "format ruby code using rubocop"
task :format do
  sh('rubocop --auto-correct')
end