# Echo and Hello Window Demo

This repository includes simple demonstration scripts that showcase echo functionality and a hello window display.

## Purpose

These scripts provide:
- **Echo functionality**: Display messages to the console with formatting
- **Hello Window**: A formatted welcome window display
- Cross-platform support (Python and Shell versions)

## Quick Start

### Python Version

Run the full demo:
```bash
python3 scripts/echo_hello.py
```

Echo a custom message:
```bash
python3 scripts/echo_hello.py --message "Your custom message here"
```

Show help:
```bash
python3 scripts/echo_hello.py --help
```

### Shell Version

Run the full demo:
```bash
bash scripts/echo_hello.sh
```

Echo a custom message:
```bash
bash scripts/echo_hello.sh Your custom message here
```

Show help:
```bash
bash scripts/echo_hello.sh --help
```

### On Windows

Using PowerShell:
```powershell
python scripts\echo_hello.py
```

Using Command Prompt:
```cmd
python scripts\echo_hello.py
```

## Output Example

When you run the default demo, you'll see:

```
2026-02-09 05:07:53,151 - INFO - Starting echo and hello window demo...
2026-02-09 05:07:53,151 - INFO - ECHO: Welcome to the demo!
>>> Welcome to the demo!
2026-02-09 05:07:53,151 - INFO - ECHO: This script demonstrates echo functionality
>>> This script demonstrates echo functionality
2026-02-09 05:07:53,151 - INFO - ECHO: And displays a hello window
>>> And displays a hello window

============================================================
                        HELLO WINDOW                        
============================================================
            Hello from MQL5 Trading Automation!             
                 Time: 2026-02-09 05:07:53                  
============================================================

2026-02-09 05:07:53,151 - INFO - Demo completed successfully
```

## Testing

Test the echo and hello window functionality:
```bash
# Run dedicated tests
python3 scripts/test_echo_hello.py

# Or run as part of full automation test suite
python3 scripts/test_automation.py
```

## Use Cases

These scripts can serve as:
- Simple templates for creating new utilities
- Examples of proper logging and error handling
- Cross-platform script development reference
- Testing and CI pipeline smoke tests

## Integration

The echo and hello window scripts are automatically tested as part of the repository's CI/CD pipeline through `scripts/test_automation.py`.
