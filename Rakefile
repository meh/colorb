#! /usr/bin/env ruby
require 'rake'

task :default => :test

task :test do
  Dir.chdir 'test'

  sh 'rspec colorb_spec.rb --color --format doc'
end
