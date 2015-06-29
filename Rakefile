require 'rubygems'

gemspec = Gem::Specification.load('lita-gitter.gemspec')

github_user, github_project =
  gemspec.homepage.scan(%r{^https://github\.com/([^/]+)/([^/]+)/?$})[0]

DEFAULT_EXCLUDE_LABELS = 'duplicate,question,invalid,wontfix'

require 'bundler/gem_tasks'

task default: [:spec, :lint]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task lint: [:rubocop]

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Generate changelog'
task :changelog, [:token] do |_t, args|
  cmd = 'github_changelog_generator'
  cmd << " -u #{github_user}"
  cmd << " -p #{github_project}"
  cmd << " -t #{args[:token]}" if args[:token]
  cmd << " --exclude-labels version,#{DEFAULT_EXCLUDE_LABELS}"

  sh cmd
end
