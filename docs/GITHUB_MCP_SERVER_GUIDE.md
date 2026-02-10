# GitHub MCP Server Guide

The GitHub MCP Server connects AI tools directly to GitHub's platform. This gives AI agents, assistants, and chatbots the ability to read repositories and code files, manage issues and PRs, analyze code, and automate workflows through natural language interactions.

## Use Cases

- **Repository Management**: Browse and query code, search files, analyze commits, and understand project structure across any repository you have access to.
- **Issue & PR Automation**: Create, update, and manage issues and pull requests. Let AI help triage bugs, review code changes, and maintain project boards.
- **CI/CD & Workflow Intelligence**: Monitor GitHub Actions workflow runs, analyze build failures, manage releases, and get insights into your development pipeline.
- **Code Analysis**: Examine security findings, review Dependabot alerts, understand code patterns, and get comprehensive insights into your codebase.
- **Team Collaboration**: Access discussions, manage notifications, analyze team activity, and streamline processes for your team.

---

## Remote GitHub MCP Server

The remote GitHub MCP Server is hosted by GitHub and provides the easiest method for getting up and running.

### Prerequisites

- A compatible MCP host with remote server support (VS Code 1.101+, Claude Desktop, Cursor, Windsurf, etc.).
- Applicable policies enabled.

### Installation in VS Code

For quick installation, use the one-click install buttons in the MCP Registry. Alternatively, manually configure VS Code by adding the appropriate JSON block to your host configuration:

#### Using OAuth
```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

#### Using a GitHub PAT
```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${input:github_mcp_pat}"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "github_mcp_pat",
      "description": "GitHub Personal Access Token",
      "password": true
    }
  ]
}
```

---

## Local GitHub MCP Server

### Prerequisites

- **Docker**: To run the server in a container.
- **GitHub Personal Access Token (PAT)**: Required for authentication.

### Installation (with Docker)

Add the following JSON block to your IDE's MCP settings:

```json
{
  "mcp": {
    "inputs": [
      {
        "type": "promptString",
        "id": "github_token",
        "description": "GitHub Personal Access Token",
        "password": true
      }
    ],
    "servers": {
      "github": {
        "command": "docker",
        "args": [
          "run",
          "-i",
          "--rm",
          "-e",
          "GITHUB_PERSONAL_ACCESS_TOKEN",
          "ghcr.io/github/github-mcp-server"
        ],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}"
        }
      }
    }
  }
}
```

### Building from Source

If you don't have Docker, you can build the binary:

1. Build in the `cmd/github-mcp-server` directory using `go build`.
2. Configure your server:
```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "/path/to/github-mcp-server",
        "args": ["stdio"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
        }
      }
    }
  }
}
```

---

## Tool Configuration

### Toolsets

The GitHub MCP Server supports enabling or disabling specific functionalities via the `--toolsets` flag.

- **Available Toolsets**: `repos`, `issues`, `pull_requests`, `actions`, `code_security`, `gists`, `git`, `orgs`, `projects`, `users`, etc.
- **Default Toolsets**: `context`, `repos`, `issues`, `pull_requests`, `users`.
- **Special Toolset 'all'**: Enables all available toolsets.

### Individual Tools

You can also configure specific tools using the `--tools` flag (e.g., `get_file_contents,issue_read,create_pull_request`).

### Specialized Modes

- **Read-Only Mode**: Use the `--read-only` flag or `GITHUB_READ_ONLY=1` to prevent modifications.
- **Lockdown Mode**: Limits content surfaced from public repositories to authors with push access. Use the `--lockdown-mode` flag or `GITHUB_LOCKDOWN_MODE=1`.
- **Dynamic Tool Discovery**: Allows the MCP host to list and enable toolsets in response to a user prompt (Beta). Use the `--dynamic-toolsets` flag.

## Customization

### i18n / Overriding Descriptions

You can override tool descriptions by creating a `github-mcp-server-config.json` file in the same directory as the binary, or by using environment variables prefixed with `GITHUB_MCP_`.

## Sharing Configuration

You can add an example (without the `mcp` key) to a file called `.vscode/mcp.json` in your workspace to share the configuration with other host applications that accept the same format.
