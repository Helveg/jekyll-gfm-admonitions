---
name: fix-and-release
description: End-to-end fix-and-ship a GitHub issue for the jekyll-gfm-admonitions gem. Use when the user says "run fix and release", "fix and release", or gives a GitHub issue link/number and asks to fix + release it. Reproduces and fixes the bug, adds a regression test, bumps the version, opens a PR linked to the issue, merges it, publishes the gem to RubyGems + GitHub release, and replies on the issue with the released version.
---

# Fix and release flow

Drives a single GitHub issue from report → fixed → published gem, for **this repo**
(`Helveg/jekyll-gfm-admonitions`, a Ruby gem). Trigger: the user gives an issue link or
number (e.g. "run fix and release https://github.com/Helveg/jekyll-gfm-admonitions/issues/20").

Take the issue number from the link/number the user gives. Below, `N` = that issue number and
`X.Y.Z` = the new version.

## Environment gotchas (this machine)

- **Use the PowerShell tool, not Bash, for git/gh/ruby.** The Bash tool mangles Windows
  backslash paths (`C:\Users\...` → `C:Users...`). The working directory is already the repo root.
- **Ruby is via rbenv.** Prefix the PATH for any `bundle`/`gem`/`rspec` command:
  ```powershell
  $env:PATH = "C:\Ruby-on-Windows\rbenv\bin;C:\Ruby-on-Windows\shims;C:\Ruby-on-Windows\3.3.6-2\bin;" + $env:PATH
  ```
  (See the `reference_ruby_location` memory; verify the active version if it has changed.)
- **`gh issue view N` plain fails** with a Projects-classic GraphQL deprecation error. Always
  pass `--json`, e.g. `gh issue view N --json number,title,body,comments,state`.
- RubyGems credentials live at `C:\Users\robin\.local\share\gem\credentials` — `gem push` works
  without extra setup. `gh` is authenticated as `Helveg` over SSH.

## Steps

1. **Read the issue.**
   ```
   gh issue view N --repo Helveg/jekyll-gfm-admonitions --json number,title,body,comments,state
   ```
   Understand the reported vs. expected behavior; note any live example links.

2. **Locate and fix the bug.** The plugin is a single file: `lib/jekyll-gfm-admonitions.rb`.
   Read it, find the root cause, and make the minimal correct fix. Match the surrounding style
   and leave a short comment referencing `issue #N` at the changed spot.

3. **Add a regression test** in `spec/jekyll_gfm_admonitions_spec.rb`. Prefer asserting on the
   exact body handed to the markdown converter (stub `markdown_converter` and capture the arg) so
   the test pins the real behavior, not the stub's wrapper. Confirm it would fail against the old
   code (reason through it).

4. **Bump the version** in `jekyll-gfm-admonitions.gemspec` (`spec.version`). Default to a **patch**
   bump (`X.Y.(Z+1)`). If the change is a feature, ask the user patch vs. minor in one line.

5. **Run the suite** — must be green before committing:
   ```powershell
   $env:PATH = "...rbenv prefix..."; bundle exec rspec
   ```

6. **Branch, commit, push.**
   ```
   git checkout -b fix/issue-N-<slug>
   git add lib/jekyll-gfm-admonitions.rb spec/jekyll_gfm_admonitions_spec.rb jekyll-gfm-admonitions.gemspec
   git commit   # message: "fix #N: <summary>" + body explaining root cause + version bump
   git push -u origin fix/issue-N-<slug>
   ```
   End the commit message with: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`.
   Stage files by path — never `git add -A`. `.gem` files are gitignored; don't commit them.

7. **Open the PR, linked to the issue.** Put `Fixes #N` in the body so GitHub links the issue and
   auto-closes it on merge.
   ```
   gh pr create --repo Helveg/jekyll-gfm-admonitions --base main --head fix/issue-N-<slug> --title "..." --body "...Fixes #N..."
   ```

8. **Check workflows.** There are **no PR-level CI checks** in this repo — the only workflow
   (`.github/workflows/jekyll.yml`, "Deploy Jekyll site to Pages") triggers on push to `main`, not
   on PRs. Confirm the PR is mergeable (`gh pr view N --json mergeable,mergeStateStatus`); the
   deploy workflow is checked *after* merge in step 10.

9. **Merge** with rebase to keep the linear history this repo uses, and update local main:
   ```
   gh pr merge <pr#> --repo Helveg/jekyll-gfm-admonitions --rebase --delete-branch
   git checkout main; git pull --ff-only origin main
   ```

10. **Release.** From `main`, with the rbenv PATH prefix:
    ```
    gem build jekyll-gfm-admonitions.gemspec        # -> jekyll-gfm-admonitions-X.Y.Z.gem
    gem push jekyll-gfm-admonitions-X.Y.Z.gem        # publishes to RubyGems (irreversible)
    git tag -a vX.Y.Z -m "vX.Y.Z - fix #N <summary>"; git push origin vX.Y.Z
    gh release create vX.Y.Z --repo Helveg/jekyll-gfm-admonitions --title "vX.Y.Z" --notes "...Fixes #N..."
    ```
    Then watch the post-merge deploy workflow to success:
    ```
    gh run list --repo Helveg/jekyll-gfm-admonitions --limit 1     # get the run id
    gh run watch <run-id> --repo Helveg/jekyll-gfm-admonitions --exit-status
    ```

11. **Reply on the issue** with the released version and a one-line description of the fix:
    ```
    gh issue comment N --repo Helveg/jekyll-gfm-admonitions --body "Fixed in **vX.Y.Z** ... https://rubygems.org/gems/jekyll-gfm-admonitions/versions/X.Y.Z"
    ```
    Confirm the issue is now `CLOSED` (the `Fixes #N` merge should have closed it).

12. **Report** to the user: the version published, PR + release links, workflow status, and that the
    issue was closed and replied to.

## Notes & guardrails

- `gem push` and `gh release create` are outward-facing and hard to reverse. The "fix and release"
  trigger authorizes them for the named issue — but if tests are red or the fix is uncertain, stop
  and surface that instead of publishing.
- Never force-push; never `--no-verify`. If a push is rejected non-fast-forward, stop and report.
- Tagging in this repo's history has been sporadic, but always create `vX.Y.Z` here for traceability.
- If multiple versions ship in a day, RubyGems versions are immutable — bump again rather than yank.
