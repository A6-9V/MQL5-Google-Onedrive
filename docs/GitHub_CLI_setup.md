# GitHub CLI Setup

## Installation

The GitHub CLI (`gh`) is available for Windows, macOS, and Linux.

### Windows

You can install the GitHub CLI on Windows using [Winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/).

```shell
winget install --id GitHub.cli
```

Alternatively, you can download the installer from the [official releases page](https://github.com/cli/cli/releases).

### macOS

If you have [Homebrew](https://brew.sh/) installed, you can use it to install the GitHub CLI.

```shell
brew install gh
```

### Linux

For Debian/Ubuntu-based distributions:

```shell
sudo apt update
sudo apt install gh
```

For Fedora/CentOS/RHEL-based distributions:

```shell
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh
```

For other Linux distributions, please refer to the [official installation instructions](https://github.com/cli/cli#installation).

## Authentication

After installing the GitHub CLI, you need to authenticate with your GitHub account.

```shell
gh auth login
```

This command will guide you through the authentication process in your browser.
