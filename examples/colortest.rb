#! /usr/bin/env ruby
require 'colorb'

0.upto(255) {|n|
  puts "#{n}".color(n)
}
