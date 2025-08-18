# Rust, MdBook & Nix Template


# Git Commit Example

```
feat: add hat wobble
^--^  ^------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: chore, docs, feat, fix, refactor, style, or test.
```

## More Examples:

- `feat`: (new feature for the user, not a new feature for build script)
- `fix`: (bug fix for the user, not a fix to a build script)
- `docs`: (changes to the documentation)
- `style`: (formatting, missing semi colons, etc; no production code change)
- `refactor`: (refactoring production code, eg. renaming a variable)
- `test`: (adding missing tests, refactoring tests; no production code change)
- `chore`: (updating grunt tasks etc; no production code change)

# Development 

## NixOS
```bash
# Open in bash by default
nix develop

# If you want other shell
nix develop -c $SHELL

# if you have direnv (optional)
direnv allow

# VSCode
code .
```

Website runs on `localhost:3000/`
```bash
mdbook serve --open
```

The development environment has whatever you may need already, but feel free to add or remove whatever
inside `shell.nix`.


## Deploying to github pages

Push your project to github repo. Open repo setting and go to Pages section and set repo branch that your book will build.

![github-pages](/rust-book/.github/assets/github-actions.png)

Then in Code tab click settings icon and tick true "Use your GitHub Pages website". It will set deployed url website

![github-pages](/rust-book/.github/assets/pages-url.png)


