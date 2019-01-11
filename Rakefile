# frozen_string_literal: true

require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'
require 'rubocop/rake_task'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp']
MetadataJsonLint.options.strict_dependencies = true
MetadataJsonLint.options.strict_puppet_version = true

desc 'Validate manifests, templates, and ruby files'
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ %r{spec\/fixtures}
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names --except Metrics/BlockLength']
end
