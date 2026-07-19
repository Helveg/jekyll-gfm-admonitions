# GitHub Flavored Admonitions

A Jekyll plugin to render GitHub-flavored admonitions in your Jekyll sites.
Supports the same `> [!TYPE]` syntax used on GitHub, with matching icons and styles.

## Supported admonitions

| **Type**      | **Markdown**          |
|---------------|-----------------------|
| Note          | `> [!NOTE]`           |
| Tip           | `> [!TIP]`            |
| Important     | `> [!IMPORTANT]`      |
| Warning       | `> [!WARNING]`        |
| Caution       | `> [!CAUTION]`        |

### Usage

```markdown
> [!NOTE]
> Highlights information that users should take into account, even when skimming.
> And supports multi-line text.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
```

> [!NOTE]
> Highlights information that users should take into account, even when skimming.
> And supports multi-line text.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.

#### Custom titles

Custom admonition titles are also supported:

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

---

## Installation

There are two setups depending on your use case:

- **[Standard Jekyll site](#standard-jekyll-site)** — you run Jekyll locally or on your own CI.
- **[GitHub Pages via GitHub Actions](#github-pages-via-github-actions)** — you deploy from a GitHub repository using the free GitHub Pages hosting.

---

## Standard Jekyll site

### 1. Add to your Gemfile

```ruby
group :jekyll_plugins do
  # other plugins ...
  gem "jekyll-gfm-admonitions"
end
```

Then install:

```bash
bundle install
```

### 2. Enable in `_config.yml`

```yaml
plugins:
  - jekyll-gfm-admonitions
```

### 3. Build or serve

```bash
bundle exec jekyll build
# or
bundle exec jekyll serve
```

During the build you will see:

```
GFMA: Converted admonitions in 36 file(s).
GFMA: Injecting admonition CSS in 36 page(s).
```

Pass `--verbose` for per-file debug output.

---

## GitHub Pages via GitHub Actions

GitHub Pages' default build pipeline does not support custom plugins. You need to
build your site with GitHub Actions instead and deploy the result. The steps below
set that up from scratch.

### 1. Enable GitHub Actions as the Pages source

1. Open your repository on GitHub.
2. Go to **Settings → Pages**.
3. Under **Build and deployment → Source**, select **GitHub Actions**.

### 2. Create the workflow file

Create `.github/workflows/jekyll.yml` in your repository:

```yaml
name: Deploy Jekyll site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5

      - name: Build with Jekyll
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 3. Create a `Gemfile`

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "jekyll"

group :jekyll_plugins do
  gem "jekyll-gfm-admonitions"
  gem "jekyll-optional-front-matter"
  gem "github-pages"
end
```

Then generate a lockfile locally (requires Ruby + Bundler):

```bash
bundle install
```

Commit both `Gemfile` and `Gemfile.lock`.

### 4. Create `_config.yml`

```yaml
title: Your Project Title
description: >-
  A description of your project.

repository: your-username/your-repository

markdown: GFM

plugins:
  - jekyll-gfm-admonitions
  - jekyll-optional-front-matter

exclude:
  - Gemfile
  - Gemfile.lock
  - vendor/
  - node_modules/
  - .sass-cache/
  - .jekyll-cache/
```

> [!CAUTION]
> For private repositories, make sure you exclude your source code files from the
> Jekyll build, or they may be publicly deployed. Add patterns for any file types
> you do not want published, for example:
> ```yaml
> exclude:
>   - "**/*.ts"
>   - "**/*.js"
>   - "*.json"
> ```

### 5. Push and verify

Push your changes to `main`. GitHub Actions will build and deploy your site automatically.
You can monitor the build under the **Actions** tab of your repository.

---

## Configuration

### Disabling CSS injection (custom themes)

By default the plugin injects its own stylesheet into every page that contains admonitions.
If your theme already provides `markdown-alert` styles (e.g. **Minimal Mistakes**, **Chirpy**,
or any theme that mirrors GitHub's admonition CSS), you can disable injection so the plugin
only handles parsing and rendering:

```yaml
gfm_admonitions:
  inject_css: false
```

When disabled the build log confirms:

```
GFMA: Converted admonitions in 36 file(s).
GFMA: CSS injection disabled (gfm_admonitions.inject_css: false).
```

The admonition HTML (`<div class="markdown-alert markdown-alert-note">` etc.) is still
emitted — your theme's CSS takes full control of the appearance.

---

## License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file
for details.

## Contributing

> [!TIP]
> Contributions are welcome! Please feel free to submit issues or pull requests.
