# frozen_string_literal: true

# jekyll-gfm-admonitions.gemspec

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-gfm-admonitions'
  spec.version       = '1.0.1'
  spec.authors       = ['Robin De Schepper']
  spec.email         = ['robin.deschepper93@gmail.com']

  spec.summary       = 'A Jekyll plugin to render GitHub-flavored admonitions.'
  spec.description   = 'This plugin allows you to use GitHub-flavored markdown syntax' \
                       'to create admonition blocks in Jekyll sites.'
  spec.homepage      = 'https://github.com/helveg/jekyll-gfm-admonitions'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb', 'assets/**/*', 'README.md', 'LICENSE.txt']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'
  spec.add_dependency 'jekyll', '~> 3.0'
  spec.add_dependency 'cssminify', '~> 1.0'
  spec.add_dependency 'octicons', '~> 19.11'
  spec.add_development_dependency 'bundler', '~> 2.0'
end
