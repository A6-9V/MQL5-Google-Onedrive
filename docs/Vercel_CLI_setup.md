# Vercel CLI Setup

## Installation

The Vercel CLI is available for Windows, macOS, and Linux.

### Via NPM (Recommended)

You can install the Vercel CLI using [npm](https://www.npmjs.com/).

```shell
npm install -g vercel
```

### macOS (Via Homebrew)

If you have [Homebrew](https://brew.sh/) installed, you can use it to install the Vercel CLI.

```shell
brew install vercel-cli
```

### Linux

Using npm is the recommended way for Linux. Ensure you have Node.js and npm installed.

```shell
npm install -g vercel
```

## Authentication

After installing the Vercel CLI, you need to authenticate with your Vercel account.

```shell
vercel login
```

This command will guide you through the authentication process in your browser or via email.

## Usage

To deploy a project:

```shell
vercel
```

To deploy to production:

```shell
vercel --prod
```
