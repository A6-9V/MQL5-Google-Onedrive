#!/usr/bin/env python3
"""
PWA Implementation Validator
Checks if all required PWA files and configurations are present.
"""

import os
import json
import sys

def check_file_exists(filepath, description):
    """Check if a file exists and return status."""
    exists = os.path.exists(filepath)
    status = "✓" if exists else "✗"
    print(f"{status} {description}: {filepath}")
    return exists

def validate_manifest(filepath):
    """Validate manifest.json structure."""
    try:
        with open(filepath, 'r') as f:
            manifest = json.load(f)
        
        required_fields = ['name', 'short_name', 'start_url', 'display', 'icons']
        missing_fields = [field for field in required_fields if field not in manifest]
        
        if missing_fields:
            print(f"  ⚠ Missing required fields: {', '.join(missing_fields)}")
            return False
        
        # Check icons
        if len(manifest.get('icons', [])) == 0:
            print(f"  ⚠ No icons defined in manifest")
            return False
        
        print(f"  ✓ Manifest is valid")
        print(f"  ✓ App name: {manifest['name']}")
        print(f"  ✓ Icons defined: {len(manifest['icons'])}")
        return True
    except json.JSONDecodeError as e:
        print(f"  ✗ Invalid JSON: {e}")
        return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def check_html_has_manifest(filepath):
    """Check if HTML file links to manifest."""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        has_manifest = 'rel="manifest"' in content or 'rel=manifest' in content
        has_sw_script = 'serviceWorker.register' in content or 'service-worker.js' in content
        
        if has_manifest:
            print(f"  ✓ Links to manifest")
        else:
            print(f"  ✗ Does not link to manifest")
        
        if has_sw_script:
            print(f"  ✓ Registers service worker")
        else:
            print(f"  ✗ Does not register service worker")
        
        return has_manifest and has_sw_script
    except Exception as e:
        print(f"  ✗ Error reading file: {e}")
        return False

def main():
    """Run PWA validation checks."""
    print("=" * 60)
    print("PWA Implementation Validator")
    print("=" * 60)
    print()
    
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(base_dir)
    
    all_checks_passed = True
    
    # Check core PWA files
    print("Core PWA Files:")
    print("-" * 60)
    core_files = [
        ("manifest.json", "Web App Manifest"),
        ("service-worker.js", "Service Worker"),
        ("sw-inspector.html", "Service Worker Inspector"),
        ("offline.html", "Offline Fallback Page"),
    ]
    
    for filepath, description in core_files:
        if not check_file_exists(filepath, description):
            all_checks_passed = False
    
    print()
    
    # Check icons directory
    print("Icons:")
    print("-" * 60)
    icons_exist = check_file_exists("icons", "Icons directory")
    if icons_exist:
        icon_svg_exists = check_file_exists("icons/icon.svg", "SVG icon template")
        if not icon_svg_exists:
            all_checks_passed = False
        
        # Check for PNG icons
        icon_sizes = [72, 96, 128, 144, 152, 192, 384, 512]
        png_icons = []
        for size in icon_sizes:
            icon_path = f"icons/icon-{size}x{size}.png"
            if os.path.exists(icon_path):
                png_icons.append(size)
        
        if png_icons:
            print(f"  ✓ Found PNG icons: {', '.join(map(str, png_icons))}x")
        else:
            print(f"  ⚠ No PNG icons found (SVG template available)")
    else:
        all_checks_passed = False
    
    print()
    
    # Validate manifest.json
    print("Manifest Validation:")
    print("-" * 60)
    if os.path.exists("manifest.json"):
        if not validate_manifest("manifest.json"):
            all_checks_passed = False
    else:
        print("✗ manifest.json not found")
        all_checks_passed = False
    
    print()
    
    # Check HTML files
    print("HTML Files:")
    print("-" * 60)
    html_files = [
        "index.html",
        "dashboard/index.html"
    ]
    
    for html_file in html_files:
        if os.path.exists(html_file):
            print(f"Checking {html_file}:")
            if not check_html_has_manifest(html_file):
                all_checks_passed = False
        else:
            print(f"✗ {html_file} not found")
            all_checks_passed = False
    
    print()
    
    # Summary
    print("=" * 60)
    if all_checks_passed:
        print("✓ All PWA checks passed!")
        print()
        print("Next steps:")
        print("1. Generate PNG icons from icons/icon.svg")
        print("2. Test the PWA in a browser with HTTPS")
        print("3. Run Lighthouse audit for PWA compliance")
        print("4. Visit /sw-inspector.html to monitor service worker")
        return 0
    else:
        print("✗ Some PWA checks failed")
        print()
        print("Please address the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
