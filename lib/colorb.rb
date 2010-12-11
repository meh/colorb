#--
# Copyleft meh. [http://meh.doesntexist.org | meh@paranoici.org]
#
# colorb is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# colorb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with colorb. If not, see <http://www.gnu.org/licenses/>.
#++

require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/

class String
  Colors = {
    :default => 9,

    :black   => 0,
    :red     => 1,
    :green   => 2,
    :yellow  => 3,
    :blue    => 4,
    :magenta => 5,
    :cyan    => 6,
    :white   => 7
  }

  Extra = {
    :default => 0,

    :bold      => 1,
    :underline => 4,
    :blink     => 5,
    :standout  => 7
  }

  (Colors.keys + Extra.keys).each {|name|
    remove_method name rescue nil
  }

  attr_reader :foreground, :background, :flags

  alias __old_method_missing method_missing

  def method_missing (id, *args, &block)
    name = id.to_s.match(/^(.+?)[!?]?$/)[1].to_sym

    return __old_method_missing(id, *args, &block) unless Colors[name] || Extra[name]

    if Colors[name]
      if id.to_s.end_with?('?')
        @foreground == name
      else
        if !foreground
          @foreground = name
        else
          @background = name
        end
      end
    elsif Extra[name]
      @flags ||= []

      if id.to_s.end_with?('?')
        @flags.member?(name)
      else
        @flags << name
      end
    end

    String.colorify(self, @foreground, @background, @flags)
  end

  def self.colorify (string, foreground, background, flags)
    return string if ENV['NO_COLOR'].nil? || ENV['NO_COLOR'].empty?

    result = string.clone

    result.sub!(/^/, [
      String.color!(foreground),
      String.color!(background, true),
      [flags].flatten.compact.map {|f|
        String.extra!(f)
      }
    ].flatten.compact.join(''))

    result.sub!(/$/, String.extra!(:default))

    result
  end

  def self.color! (name, bg=false)
    "\e[#{Colors[name] + (bg ? 40 : 30)}m" if Colors[name]
  end

  def self.extra! (name)
    "\e[#{Extra[name]}m" if Extra[name]
  end
end
