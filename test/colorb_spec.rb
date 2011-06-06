#! /usr/bin/env ruby
require 'rubygems'
require 'colorb'

describe String do
  before do
    @string = 'lol'
    @string.freeze
  end

  Hash[
    [:clean]     => "\e[0mlol\e[0m",
    [:bold]      => "\e[1mlol\e[0m",
    [:underline] => "\e[4mlol\e[0m",
    [:blink]     => "\e[5mlol\e[0m",
    [:standout]  => "\e[7mlol\e[0m",


    [:default] => "\e[39mlol\e[0m",
    [:black]   => "\e[30mlol\e[0m",
    [:red]     => "\e[31mlol\e[0m",
    [:green]   => "\e[32mlol\e[0m",
    [:yellow]  => "\e[33mlol\e[0m",
    [:blue]    => "\e[34mlol\e[0m",
    [:magenta] => "\e[35mlol\e[0m",
    [:cyan]    => "\e[36mlol\e[0m",
    [:white]   => "\e[37mlol\e[0m",

    [:default, :default] => "\e[39m\e[49m\e[39mlol\e[0m\e[0m",
    [:default, :black]   => "\e[39m\e[40m\e[39mlol\e[0m\e[0m",
    [:default, :red]     => "\e[39m\e[41m\e[39mlol\e[0m\e[0m",
    [:default, :green]   => "\e[39m\e[42m\e[39mlol\e[0m\e[0m",
    [:default, :yellow]  => "\e[39m\e[43m\e[39mlol\e[0m\e[0m",
    [:default, :blue]    => "\e[39m\e[44m\e[39mlol\e[0m\e[0m",
    [:default, :magenta] => "\e[39m\e[45m\e[39mlol\e[0m\e[0m",
    [:default, :cyan]    => "\e[39m\e[46m\e[39mlol\e[0m\e[0m",
    [:default, :white]   => "\e[39m\e[47m\e[39mlol\e[0m\e[0m",

    [:red, :white, :bold,  :blink, :standout, :underline] => "\e[31m\e[47m\e[1m\e[5m\e[7m\e[4m\e[31m\e[47m\e[1m\e[5m\e[7m\e[31m\e[47m\e[1m\e[5m\e[31m\e[47m\e[1m\e[31m\e[47m\e[31mlol\e[0m\e[0m\e[0m\e[0m\e[0m\e[0m"
  ].each {|methods, value|
    describe ([nil] + methods).join('.') do
      it 'returns the right ascii codes' do
        result = @string

        methods.each {|meth|
          result = result.send meth
        }

        result.should == value
      end
    end
  }
end
