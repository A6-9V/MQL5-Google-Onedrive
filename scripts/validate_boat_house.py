#!/usr/bin/env python3
"""
Validate boat-house integration
"""

import os
import sys
from pathlib import Path

def check_directory_exists(path, description):
    """Check if a directory exists."""
    if os.path.isdir(path):
        print(f"✓ {description}: {path}")
        return True
    else:
        print(f"✗ {description}: {path} NOT FOUND")
        return False

def check_file_exists(path, description):
    """Check if a file exists."""
    if os.path.isfile(path):
        print(f"✓ {description}: {path}")
        return True
    else:
        print(f"✗ {description}: {path} NOT FOUND")
        return False

def main():
    """Main validation function."""
    print("=" * 60)
    print("Boat-house Integration Validation")
    print("=" * 60)
    
    repo_root = Path(__file__).parent.parent
    boat_house_dir = repo_root / "boat-house"
    
    checks = []
    
    # Check boat-house directory
    checks.append(check_directory_exists(
        boat_house_dir, 
        "Boat-house root directory"
    ))
    
    # Check main service directories
    services = [
        "client", "management", "statistics-service",
        "product-service", "account-service"
    ]
    
    print("\nService Directories:")
    for service in services:
        service_path = boat_house_dir / service
        checks.append(check_directory_exists(
            service_path,
            f"  {service.capitalize()} service"
        ))
    
    # Check key files
    print("\nKey Files:")
    checks.append(check_file_exists(
        boat_house_dir / "README.md",
        "  Boat-house README"
    ))
    checks.append(check_file_exists(
        boat_house_dir / "docker-compose.yml",
        "  Docker Compose config"
    ))
    checks.append(check_file_exists(
        boat_house_dir / "LICENSE",
        "  License file"
    ))
    
    # Check integration documentation
    print("\nIntegration Documentation:")
    checks.append(check_file_exists(
        repo_root / "docs" / "Boat_House_Integration.md",
        "  Integration guide"
    ))
    
    # Check README update
    print("\nProject Updates:")
    readme_path = repo_root / "README.md"
    if os.path.isfile(readme_path):
        with open(readme_path, 'r') as f:
            content = f.read()
            if "boat-house" in content.lower():
                print(f"✓ README.md mentions boat-house")
                checks.append(True)
            else:
                print(f"✗ README.md does not mention boat-house")
                checks.append(False)
    
    # Summary
    print("\n" + "=" * 60)
    passed = sum(checks)
    total = len(checks)
    print(f"Validation Results: {passed}/{total} checks passed")
    
    if passed == total:
        print("✓ All validation checks passed!")
        return 0
    else:
        print(f"✗ {total - passed} check(s) failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
