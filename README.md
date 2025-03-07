# GitHub Flavored Admonitions

A Jekyll plugin to render GitHub-flavored admonitions in your Jekyll sites.
This plugin allows you to use GitHub-flavored markdown syntax to create stylish admonition
blocks for notes, warnings, tips, cautions, and important messages.

## Features

* Admonitions
* Admonition titles
* Jekyll support
* GitHub Pages support

## Supported Admonitions

The following admonitions are supported:

| **Type**      | **Markdown**          |
|---------------|-----------------------|
| Note          | `> [!NOTE]`           |
| Tip           | `> [!TIP]`            |
| Important     | `> [!IMPORTANT]`      |
| Warning       | `> [!WARNING]`        |
| Caution       | `> [!CAUTION]`        |


### Example Usage

To use admonitions in your markdown files, simply add the following syntax:

```markdown
> [!NOTE]
> Highlights information that users should take into account, even when skimming.
> And supports multi-line text.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

  > [!WARNING]  
  > Critical content demanding immediate
  > user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
> Opportunity to provide more context.
```

> [!NOTE]
> Highlights information that users should take into account, even when skimming.
> And supports multi-line text.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

  > [!WARNING]  
  > Critical content demanding immediate
  > user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
> Opportunity to provide more context.

#### Custom titles

Custom admonition titles are supported:

```markdown
> [!TIP] My own title
> Fancy!
```

> [!TIP] My own title
> Fancy!

> [!NOTE]
> GFM itself does not support this syntax, so this will only work in your
> [build output](https://helveg.github.io/jekyll-gfm-admonitions/#custom-titles),
> but not on your
> [GitHub rendered README](https://github.com/Helveg/jekyll-gfm-admonitions/blob/main/README.md#custom-titles)s
> etc.


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

Then, during `build`/`serve`, you should see logs similar to:

```
GFMA: Converted adminitions in 36 file(s).
GFMA: Injecting admonition CSS in 36 page(s).
```

More details are available by passing the `--verbose` flag to your `jekyll` command.

## When using GitHub Pages

To enable custom plugins in your Jekyll build for GitHub Pages, you need to use GitHub
Actions (GHA) to build and deploy your Jekyll site. For detailed instructions on setting
up GitHub Actions for your Jekyll project, please follow this link: 
[GitHub Actions Setup for Jekyll](https://jekyllrb.com/docs/continuous-integration/github-actions/).

After following the steps you will have to set up a minimal valid Jekyll project.

### Add a `_config.yml`

```yaml
# Site settings
title: Your Project Title
repository: your-username/your-repository
description: >-
  A description of your project

markdown: GFM 
plugins:
- jekyll-gfm-admonitions
- jekyll-optional-front-matter

exclude: 
  - "**/*.ts" # Exclude source code files!
  - "**/*.js"
  - "*.ts" # Also those in the root directory!
  - "*.js"
  - "*.json" # Don't forget about assets!
  - node_modules/ # And large vendored directories
  # And these ignore all the artifacts the build produces:
  - .sass-cache/
  - .jekyll-cache/
  - gemfiles/
  - Gemfile
  - Gemfile.lock
  - vendor/bundle/
  - vendor/cache/
  - vendor/gems/
  - vendor/ruby/
```

> [!CAUTION]
>
> For private repositories, make sure you exclude your source code files from the Jekyll
> build, or they might be publicly deployed! Also exclude large vendored package
> directories such as `node_modules/`.

### Add a `Gemfile`:

```ruby
source 'https://rubygems.org'
 
gem 'jekyll'
group :jekyll_plugins do
  gem 'jekyll-gfm-admonitions'
  gem 'jekyll-optional-front-matter'
  gem 'github-pages'
end
gem 'jekyll-remote-theme'
```

## License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file
for details.

## Contributing


> [!TIP]
> Contributions are welcome! Please feel free to submit issues or pull requests.