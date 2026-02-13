# Gemini CLI Setup

## Installation

The Gemini CLI is an official tool from Google to interact with Gemini models from your terminal.

Install it globally using npm:

```shell
sudo npm install -g @google/gemini-cli
```

## Authentication

The Gemini CLI requires a Google AI API Key. You can get one from [Google AI Studio](https://aistudio.google.com/).

### Option 1: Environment Variable (Recommended)

Set the `GEMINI_API_KEY` environment variable in your shell profile or `.env` file:

```shell
export GEMINI_API_KEY="your_api_key_here"
```

### Option 2: Settings File

You can also set the API key in the Gemini CLI settings file at `~/.gemini/settings.json`:

```json
{
  "auth": {
    "apiKey": "your_api_key_here"
  }
}
```

## Usage

### Interactive Mode

Simply run the command to start a chat:

```shell
gemini
```

### Non-Interactive Mode

Send a single prompt and exit:

```shell
gemini --prompt "What is the capital of France?"
```

### Using a Specific Model

```shell
gemini --model gemini-2.0-flash --prompt "Analyze this code..."
```

## Quick Verification

Check the version to ensure it is installed correctly:

```shell
gemini --version
```
