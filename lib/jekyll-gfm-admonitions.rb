# frozen_string_literal: true

require 'octicons'
require 'cssminify'

ADMONITION_ICONS = {
  'important' => 'report',
  'note' => 'info',
  'tip' => 'light-bulb',
  'warning' => 'alert',
  'caution' => 'stop'
}.freeze

# JekyllGFMAdmonitions is a module that provides functionality to process and
# convert GitHub-flavored markdown admonitions into HTML within Jekyll.
module JekyllGFMAdmonitions
  # GFMAdmonitionConverter is a Jekyll generator that converts custom
  # admonition blocks in markdown (e.g., `> [!IMPORTANT]`) into styled HTML
  # alert boxes with icons.
  #
  # This generator processes both posts and pages, replacing admonition
  # syntax with HTML markup that includes appropriate iconography and CSS styling.
  class GFMAdmonitionConverter < Jekyll::Generator
    safe true

    def initialize(*args)
      super(*args)
      @converted = 0
    end

    def generate(site)
      # Process admonitions in posts
      site.posts.docs.each do |doc|
        process(doc)
      end

      # Process admonitions in pages
      site.pages.each do |page|
        process(page)
      end

      Jekyll.logger.info 'GFMA:', "Converted adminitions in #{@converted} file(s)."
    end

    def process(doc)
      original_content = doc.content.dup
      convert_admonitions(doc)

      return unless doc.content != original_content

      inject_css(doc)
      @converted += 1
    end

    def convert_admonitions(doc)
      doc.content.gsub!(/>\s*\[!(IMPORTANT|NOTE|WARNING|TIP|CAUTION)\]\s*\n((?:>.*\n?)*)/) do
        type = ::Regexp.last_match(1).downcase
        title = type.capitalize
        text = ::Regexp.last_match(2).gsub(/^>\s*/, '').strip
        icon = Octicons::Octicon.new(ADMONITION_ICONS[type]).to_svg

        "<div class='markdown-alert markdown-alert-#{type}'>
          <p class='markdown-alert-title'>#{icon} #{title}</p>
          <p>#{text}</p>
        </div>"
      end
    end

    def inject_css(doc)
      css = File.read(File.expand_path('../assets/admonitions.css', __dir__))
      doc.content += "<style>#{CSSminify.compress(css)}</style>"
    end
  end
end
