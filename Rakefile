require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

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

task default: %i[readme doc test]
