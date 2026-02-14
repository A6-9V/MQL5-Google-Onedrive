# Contributing to MQL5 Trading Automation

Thank you for your interest in contributing to this project! This guide outlines the standards and practices we follow.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a code of professional conduct. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for your contributions
- Prioritize the project's best interests

## Getting Started

### Prerequisites

- Python 3.8+
- Docker and Docker Compose
- Git
- MetaTrader 5 (for MQL5 development)
- VS Code (recommended)

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/A6-9V/MQL5-Google-Onedrive.git
   cd MQL5-Google-Onedrive
   ```

2. **Open the workspace**:
   ```bash
   code MQL5-Trading-Automation.code-workspace
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   pip install -r scripts/requirements_bot.txt
   ```

4. **Validate your setup**:
   ```bash
   python scripts/ci_validate_repo.py
   python scripts/test_automation.py
   ```

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Creating a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

## Coding Standards

### General Principles

1. **Keep it Simple**: Write clear, maintainable code
2. **DRY (Don't Repeat Yourself)**: Avoid code duplication
3. **Single Responsibility**: Each function/class should have one purpose
4. **Explicit is Better**: Use clear variable and function names
5. **Test Your Code**: Write tests for new functionality

### Python Code Standards

- **Style Guide**: Follow [PEP 8](https://pep8.org/)
- **Formatting**: Use `black` for automatic formatting
- **Linting**: Use `pylint` to catch errors
- **Type Hints**: Use type hints where appropriate

```python
# Good example
def calculate_lot_size(
    risk_percent: float,
    stop_loss_points: int,
    account_balance: float
) -> float:
    """Calculate position size based on risk parameters.
    
    Args:
        risk_percent: Risk percentage (0-100)
        stop_loss_points: Stop loss distance in points
        account_balance: Account balance in base currency
        
    Returns:
        Calculated lot size
    """
    risk_amount = account_balance * (risk_percent / 100)
    lot_size = risk_amount / (stop_loss_points * 10)
    return round(lot_size, 2)
```

### MQL5 Code Standards

- **Naming**: Use PascalCase for functions, camelCase for variables
- **Comments**: Use `//` for single-line, `/* */` for multi-line
- **Input Variables**: Group related inputs together
- **Error Handling**: Always check return values

```mql5
// Good example
input group "Risk Management"
input double RiskPercent = 1.0;        // Risk per trade (%)
input bool   RiskUseEquity = true;     // Use equity instead of balance

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                  |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
    if (slDistance <= 0) return 0.0;
    
    double accountSize = RiskUseEquity ? AccountInfoDouble(ACCOUNT_EQUITY) 
                                       : AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountSize * (RiskPercent / 100.0);
    
    double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double lotSize = riskAmount / (slDistance * pointValue);
    
    return NormalizeLots(lotSize);
}
```

### Bash/Shell Script Standards

- Use `#!/bin/bash` shebang
- Use `set -e` for exit on error
- Quote all variables: `"$variable"`
- Use functions for reusability
- Add help text with `-h` flag

```bash
#!/bin/bash
set -e

# Good example
function validate_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    return 0
}
```

### Docker Standards

- Use multi-stage builds where appropriate
- Keep images small (use Alpine when possible)
- Don't run as root user
- Pin base image versions
- Use `.dockerignore` to exclude unnecessary files

## Testing Guidelines

### Required Tests

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test component interactions
3. **Validation Tests**: Ensure code meets requirements

### Running Tests

```bash
# Run repository validation
python scripts/ci_validate_repo.py

# Run automation tests
python scripts/test_automation.py

# Package MT5 files (smoke test)
bash scripts/package_mt5.sh
```

### Writing Tests

```python
# Example test structure
import pytest

def test_calculate_lot_size():
    """Test lot size calculation."""
    result = calculate_lot_size(
        risk_percent=1.0,
        stop_loss_points=50,
        account_balance=10000.0
    )
    
    assert result > 0
    assert result <= 10.0  # Reasonable max lot size
```

## Documentation Standards

### Code Documentation

- **Functions**: Always include docstrings
- **Classes**: Document purpose and usage
- **Complex Logic**: Add inline comments explaining why
- **TODOs**: Mark with `TODO:` and your initials

### Markdown Documentation

- Use clear headings (h1-h6)
- Include table of contents for long documents
- Use code blocks with language syntax highlighting
- Keep lines under 100 characters when possible
- Use relative links for internal documents

### README Updates

When making changes that affect usage:

1. Update the main README.md
2. Update relevant documentation in `docs/`
3. Update CHANGELOG.md
4. Ensure all links work

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

### Examples

```bash
feat(ea): add Gemini AI integration for trade confirmation

Implement AI-powered trade confirmation using Google Gemini API.
Users can now enable AI filtering to get intelligent trade analysis
before entry.

Closes #123

---

fix(scripts): correct path handling in package_mt5.sh

The script was using relative paths incorrectly on Windows.
Changed to use absolute paths with proper path resolution.

---

docs: update README with new workspace configuration

Add instructions for using the new VS Code workspace file.
```

## Pull Request Process

### Before Submitting

1. **Test your changes**:
   ```bash
   python scripts/ci_validate_repo.py
   python scripts/test_automation.py
   ```

2. **Update documentation** if needed

3. **Format your code**:
   ```bash
   black scripts/*.py
   ```

4. **Check your commits** follow the guidelines

### PR Template

Use the provided PR template. Include:

- Clear description of changes
- Link to related issues
- Screenshots (for UI changes)
- Testing performed
- Breaking changes (if any)

### Review Process

1. **Automated checks** must pass (CI/CD)
2. **Code review** by at least one maintainer
3. **Testing** in the reviewer's environment
4. **Documentation** review if docs changed
5. **Merge** after approval

### Auto-merge

PRs with the `automerge` label will auto-merge once:

- All required checks pass
- Required reviews are approved
- No conflicts exist

## Development Environment

### Using DevContainer

The project includes a DevContainer configuration:

```bash
# Open in VS Code with DevContainer extension
code MQL5-Trading-Automation.code-workspace
# Press F1 -> "Dev Containers: Reopen in Container"
```

### Using Docker Compose

```bash
# Development environment
docker-compose -f docker-compose.dev.yml up -d

# Enter the container
docker exec -it mql5-trading-dev bash

# Run tests inside container
python scripts/ci_validate_repo.py
```

### Manual Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
pip install -r scripts/requirements_bot.txt
```

## File Organization

```
.
├── .devcontainer/        # DevContainer configuration
├── .github/              # GitHub workflows and templates
├── .vscode/              # VS Code settings
├── config/               # Configuration files
├── dashboard/            # Web dashboard files
├── docs/                 # Documentation
├── mt5/MQL5/            # MQL5 source code
│   ├── Experts/         # Expert Advisors
│   ├── Indicators/      # Indicators
│   └── Include/         # Shared libraries
├── scripts/             # Automation scripts
└── MQL5-Trading-Automation.code-workspace  # VS Code workspace
```

## Getting Help

- **Documentation**: Check `docs/INDEX.md` for all guides
- **Issues**: Open an issue on GitHub
- **Questions**: Use GitHub Discussions
- **Community**: Join our [WhatsApp Agent Community](https://chat.whatsapp.com/DYemXrBnMD63K55bjUMKYF)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

Thank you for contributing! 🚀
