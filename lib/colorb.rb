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
    :clean => 0,

    :bold      => 1,
    :underline => 4,
    :blink     => 5,
    :standout  => 7
  }

  (Colors.keys + Extra.keys).each {|name|
    remove_method name rescue nil
  }

  attr_accessor :foreground, :background, :flags

  alias __old_method_missing method_missing

  def method_missing (id, *args, &block)
    name = id.to_s.match(/^(.+?)[!?]?$/)[1].to_sym

    result = (self.frozen? || !id.to_s.end_with?('!')) ? self.dup : self

    return __old_method_missing(id, *args, &block) unless Colors[name] || Extra[name]

    if Colors[name]
      if id.to_s.end_with?('?')
        result.foreground == name
      else
        if !result.foreground
          result.foreground = name
        else
          result.background = name
        end
      end
    elsif Extra[name]
      result.flags ||= []

      if id.to_s.end_with?('?')
        result.flags.member?(name)
      else
        result.flags << name
      end
    end

    result.lazy? ? result : result.colorify!
  end

  def color (code, second=nil)
    return method_missing(code.to_sym) if code.is_a?(Symbol) || code.is_a?(String)

    self.dup.color!(code, seond)
  end

  def color! (code, second=nil)
    if code < 16
      if code > 7
        (self.flags ||= []) << (!self.foreground ? :bold : :blink)
      end

      if !self.foreground
        self.foreground = code - (code > 7 ? 7 : 0)
      else
        self.background = code - (code > 7 ? 7 : 0)
      end
    else
      if !self.foreground
        self.foreground = code
      else
        self.background = code
      end
    end

    self.color(second) if second

    self.lazy? ? self : self.colorify!
  end

  def lazy;  @lazy = true; self end
  def lazy?; @lazy              end

  def colorify!
    String.colorify(self, @foreground, @background, @flags)
  end

  def self.colorify (string, foreground, background, flags)
    return string if ENV['NO_COLORS'] && !ENV['NO_COLORS'].empty?

    result = string.dup

    result.sub!(/^/, [
      String.color!(foreground),
      String.color!(background, true),
      [flags].flatten.compact.uniq.map {|f|
        String.extra!(f)
      }
    ].flatten.compact.join(''))

    result.sub!(/$/, String.extra!(:clean))

    result
  end

  def self.color! (what, bg=false)
    if what.is_a?(Symbol) || what.is_a?(String)
      "\e[#{Colors[what.to_sym] + (bg ? 40 : 30)}m" if Colors[what.to_sym]
    elsif what.is_a?(Numeric)
      if what < 8
        "\e[#{what + (bg ? 40 : 30)}m"
      else
        "\e[#{bg ? 48 : 38};5;#{what}m"
      end
    end
  end

  def self.extra! (what)
    Extra[what] ? "\e[#{Extra[what]}m" : "\e[#{what}m"
  end
end
