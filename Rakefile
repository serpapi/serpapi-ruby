require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require_relative 'lib/serpapi'

task :check do
  if ENV['API_KEY']
    puts 'found $API_KEY'
  else
    puts 'API_KEY must be defined'
    exit 1
  end
end

task readme: ['README.md.erb'] do
  `erb -T '-' README.md.erb > README.md`
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/search/*.rb']
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

task oobt: %i[check build] do
  sh 'gem install `ls -t1 *.gem | head -1`'
  sh 'ruby oobt/demo.rb'
end

task :version do
  puts 'current version: ' + SerpApi::Client::VERSION
end

task :tag do
  version = SerpApi::Client::VERSION
  puts "create git tag #{version}"
  sh "git tag #{version}"
  puts "now publish the tag:\n$ git push origin #{version}"
end

task :release do
  sh 'gem push `ls -t1 *.gem | head -1`'
  puts 'release public on: https://rubygems.org/gems/serpapi/versions'
end

task default: %i[dependency version readme doc build test oobt]
