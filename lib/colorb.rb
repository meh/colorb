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
require 'color'

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

  attr_accessor :foreground, :background, :flags

  Colors.keys.each {|name|
    define_method name do |*args|
      color(name)
    end

    define_method "#{name}!" do |*args|
      color!(name)
    end
  }

  Extra.keys.each {|name|
    define_method name do |*args|
      extra(name)
    end

    define_method "#{name}!" do |*args|
      extra!(name)
    end
  }

  def color (code, second=nil)
    self.dup.color!(code, second)
  end

  def color! (code, second=nil)
    string = (self.frozen?) ? self.dup : self

    if code.is_a?(Symbol) || code.is_a?(String)
      if !string.foreground
        string.foreground = code
      else
        string.background = code
      end

      string.lazy? ? string : string.colorify!
    else
      if code < 16
        if code > 7
          (string.flags ||= []) << (!string.foreground ? :bold : :blink)
        end

        if !string.foreground
          string.foreground = code - (code > 7 ? 7 : 0)
        else
          string.background = code - (code > 7 ? 7 : 0)
        end
      else
        if !string.foreground
          string.foreground = code
        else
          string.background = code
        end
      end
    end

    string.color!(second) if second

    string.lazy? ? string : string.colorify!
  end

  def extra (name)
    self.dup.extra!(name)
  end

  def extra! (name)
    string = (self.frozen?) ? self.dup : self

    (string.flags ||= []) << name

    string.lazy? ? string : string.colorify!
  end

  def lazy;  @lazy = true; self end
  def lazy?; @lazy              end

  def colorify!
    String.colorify(self, @foreground, @background, @flags)
  end

  def self.colorify (string, foreground, background, flags)
    return string if ENV['NO_COLORS'] && !ENV['NO_COLORS'].empty?

    string = string.dup

    string.sub!(/^/, [
      String.color!(foreground),
      String.color!(background, true),
      [flags].flatten.compact.uniq.map {|f|
        String.extra!(f)
      }
    ].flatten.compact.join(''))

    string.sub!(/$/, String.extra!(:clean))

    string
  end

  def self.color! (what, bg=false)
    if what.is_a?(Symbol) || what.is_a?(String)
      if Colors[what.to_sym]
        "\e[#{Colors[what.to_sym] + (bg ? 40 : 30)}m"
      else
        color = Color::RGB.from_html(what.to_s)

        "\e[#{bg ? 48 : 38};2;#{color.red.to_i};#{color.green.to_i};#{color.blue.to_i}m"
      end
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
