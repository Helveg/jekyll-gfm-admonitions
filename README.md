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

## License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file
for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.