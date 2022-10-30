# Git Semantic Versioning

## Table Of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Contributing](#contributing)

## Introduction

A git plugin to manage versioning applying [Semantic Versioning 2.0.0].

Project contains some code from https://github.com/markchalloner/git-semver

## Installation

Clone the repository and create a symlink to `git-semver.sh` in a folder in the `PATH`

``` bash
$ git clone https://github.com/mrulex-repo/git-semver.git
$ ln -s $HOME/.local/bin/git-semver
```

## Usage

``` bash
git semver <action>
```

To check all available actions please check `git semver help`


## Configuration

Git-semver will check for a configuration file in the following locations and use the first one that exists:

- `$GIT_REPO_ROOT/.git-semver`
- `$XDG_CONFIG_HOME/.git-semver/config`
- `$HOME/.git-semver/config`

Git-semver will default to `$HOME/.git-semver/config` if no configuration file is found.

An example configuration file with the default settings can be found at [config.example].

## Updates

Updates can be done using `git pull`.

## Uninstallation

Remove symlink and repository

[config.example]: config.example
[Semantic Versioning 2.0.0]: http://semver.org/spec/v2.0.0.html
