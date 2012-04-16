# Title: Simple Abbreviation tag for Jekyll
# Authors: Christopher Petrilli
# Description: Easily output abbreviations with proper HTML5 markup.
#
# Syntax {% abbr [abbreviation | "abbreviation"] [title text | "title text"] %}
#
# Examples:
# {% img /images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png 150 150 "Ninja Attack!" "Ninja in attack posture" %}
#
# Output:
# <img src="/images/ninja.png">
# <img class="left half" src="http://site.com/images/ninja.png" title="Ninja Attack!" alt="Ninja Attack!">
# <img class="left half" src="http://site.com/images/ninja.png" width="150" height="150" title="Ninja Attack!" alt="Ninja in attack posture">
#

module Jekyll

  class AbbrTag < Liquid::Tag
    @abbreviation = nil
    @title = nil

    def initialize(tag_name, markup, tokens)
      if markup =~ /\A(\S+)\s([\S ]+)/i
        @abbreviation = $1
        @title = $2
      end
      super
    end

    def render(context)
      if @abbreviation
        "<abbr title=#{@title}>#{@abbreviation}</abbr>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('abbr', Jekyll::AbbrTag)
