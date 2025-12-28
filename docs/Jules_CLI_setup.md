# Jules CLI Setup

## Installation

The easiest way to get started is with npm:

```shell
npm install -g @google/jules
```

## Authentication

Before you can use the tool, you must authenticate with your Google account.

```shell
jules login
```

This command will open a browser window to guide you through the Google authentication process.

## GitHub org + private repo access (required)

If you’re working in an **organization** (or on **private repositories**), you must also install/authorize the **Jules GitHub App** for the org. Installing it only on a personal account does **not** automatically grant access to org repos.

- **Install Jules on the org account (separately)**:
  - In GitHub, open the **organization** → **Settings** → **GitHub Apps** (or “Installed GitHub Apps”).
  - Find **Jules** and **Install** it for the org.
  - Choose **All repositories** or explicitly select the repos Jules should access.

- **Private repos need explicit permissions**:
  - For private repos, the GitHub App must be granted **repository access** and the required permissions.
  - In practice this commonly means allowing **full `repo` access/control** (or equivalent “Repository contents” + PR permissions), otherwise Jules will not be able to read/write PRs or fetch repo contents.

## Refresh Jules after GitHub authorization

After you install/approve the GitHub App permissions (especially changing org/private-repo access), refresh Jules so it re-reads the updated authorization state:

1. **Close and restart** Jules (exit the TUI, re-run `jules`, or re-run your `jules new ...` command).
2. If the newly-authorized repos still don’t appear or actions still fail, force a clean re-auth:

```shell
jules logout
jules login
```

## Quick verification

Use these commands to sanity-check connectivity after setup/authorization changes:

```shell
jules version
jules remote list --repo
```
