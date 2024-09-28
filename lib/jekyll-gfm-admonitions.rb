# frozen_string_literal: true

require 'octicons'
require 'cssminify'
require 'liquid/template'

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
    priority :lowest
    @@admonition_pages = []

    def initialize(*args)
      super(*args)
      @converted = 0
    end

    def generate(site)
      @markdown = site.converters.find { |c| c.is_a?(Jekyll::Converters::Markdown) }
      unless @markdown
        raise "Markdown converter not found. Please ensure that you have a markdown converter configured in your Jekyll site."
      end

      # Process admonitions in posts
      site.posts.docs.each do |doc|
        Jekyll.logger.debug 'GFMA:', "Processing post '#{doc.path}' (#{doc.content.length} characters)."
        process(doc)
      end

      # Process admonitions in pages
      site.pages.each do |page|
        # Patch the root README for GitHub Pages builds
        if page.path == 'README.md' && page.dir == '/'
          Jekyll.logger.info 'GFMA:', "Patched /README.html to /index.html"
          page.instance_variable_set(:@url, '/index.html')
        end
        Jekyll.logger.debug 'GFMA:', "Processing page '#{page.path}' (#{page.content.length} characters)."
        process(page)
      end

      Jekyll.logger.info 'GFMA:', "Converted adminitions in #{@converted} file(s)."
    end

    def process(doc)
      original_content = doc.content.dup
      convert_admonitions(doc)

      return unless doc.content != original_content

      @@admonition_pages << doc
      @converted += 1
    end

    def self.admonition_pages
      return @@admonition_pages
    end

    def convert_admonitions(doc)
      code_blocks = []
      doc.content.gsub!(/(?:^|\n)(?<!>)\s*```.*?```/m) do |match|
        code_blocks << match
        "```{{CODE_BLOCK_#{code_blocks.length - 1}}}```"
      end

      doc.content.gsub!(/>\s*\[!(IMPORTANT|NOTE|WARNING|TIP|CAUTION)\]\s*\n((?:>.*\n?)*)/) do
        type = ::Regexp.last_match(1).downcase
        title = type.capitalize
        text = ::Regexp.last_match(2).gsub(/^>\s*/, '').strip
        icon = Octicons::Octicon.new(ADMONITION_ICONS[type]).to_svg
        Jekyll.logger.debug 'GFMA:', "Converting #{type} admonition."

        "<div class='markdown-alert markdown-alert-#{type}'>
          <p class='markdown-alert-title'>#{icon} #{title}</p>
          <p>#{@markdown.convert(text)}</p>
        </div>\n\n"
      end

      doc.content.gsub!(/```\{\{CODE_BLOCK_(\d+)}}```/) do
        code_blocks[$1.to_i]
      end
    end
  end

  Jekyll::Hooks.register :site, :post_render do |site|
    Jekyll.logger.info 'GFMA:', "Injecting admonition CSS in #{GFMAdmonitionConverter.admonition_pages.length} page(s)."

    for page in GFMAdmonitionConverter.admonition_pages do
      Jekyll.logger.debug 'GFMA:', "Appending admonition style to '#{page.path}'."
      css = File.read(File.expand_path('../assets/admonitions.css', __dir__))

      page.output += "<style>#{CSSminify.compress(css)}</style>"
    end
  end
end
