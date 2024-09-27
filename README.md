# GitHub Flavored Admonitions

A Jekyll plugin to render GitHub-flavored admonitions in your Jekyll sites.
This plugin allows you to use GitHub-flavored markdown syntax to create stylish admonition
blocks for notes, warnings, tips, cautions, and important messages.

## Supported Admonitions

The following admonitions are supported:

- **Important**: `> [!IMPORTANT]`
- **Note**: `> [!NOTE]`
- **Tip**: `> [!TIP]`
- **Warning**: `> [!WARNING]`
- **Caution**: `> [!CAUTION]`

### Example Usage

To use admonitions in your markdown files, simply add the following syntax:

```markdown
> [!IMPORTANT]
> This is an important message.

> [!NOTE]
> This is a note.

> [!TIP]
> This is a helpful tip.

> [!WARNING]
> This is a warning.

> [!CAUTION]
> This is a caution message.
```

> [!IMPORTANT]
> This is an important message.

> [!NOTE]
> This is a note.

> [!TIP]
> This is a helpful tip.

> [!WARNING]
> This is a warning.

> [!CAUTION]
> This is a caution message.

## Installation

To install the plugin, add it to your Jekyll project's `Gemfile`:

```ruby
group :jekyll_plugins do
   
   # Other plugins go here ...
   
   # ... Add this line:
   gem "jekyll-gfm-admonitions"
end
```

Then run:

```bash
bundle install
```

### Configuring Jekyll

Next, you need to enable the plugin in your Jekyll configuration file (`_config.yml`):

```yaml
plugins:
  - jekyll-gfm-admonitions
```

Then, during build/serve, you should see a log similar to:

```
GFMA: Converted adminitions in 1 file(s).
```

## When using GitHub Pages

To enable custom plugins in your Jekyll build for GitHub Pages, you need to use GitHub
Actions (GHA) to build and deploy your Jekyll site. For detailed instructions on setting
up GitHub Actions for your Jekyll project, please follow this link: 
[GitHub Actions Setup for Jekyll](https://jekyllrb.com/docs/continuous-integration/github-actions/).

After following the steps you will have to set up a minimal valid Jekyll project:

1. Add `_config.yml`:

   ```yaml
   # Site settings
   title: YouProjectName
   repository: your-username/your-repository
   description: >-
     A description of your project

   markdown: GFM 
   plugins:
   - jekyll-gfm-admonitions
   
   exclude:
     - SEE NOTE
   ```
   
   > [!CAUTION]
   >
   > For private repositories, make sure you exclude your source code files, or Jekyll may
   > include them in the output! Also exclude large vendored package directories such as
   > `node_modules/`.

2. Add a `Gemfile`:

   ```ruby
   source 'https://rubygems.org'
    
   gem 'jekyll'
   group :jekyll_plugins do
     gem 'jekyll-gfm-admonitions', '~> 0.2.1'
     gem 'github-pages'
   end
   gem 'jekyll-remote-theme'
   ```

3. Make sure that all your `.md` files contain [front matter](https://jekyllrb.com/docs/front-matter/):

   ```markdown
   ---
   ---
   
   # Jekyll only processes files with front matter
   ```

## License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file
for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.