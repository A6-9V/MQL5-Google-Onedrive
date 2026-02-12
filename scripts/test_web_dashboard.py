import unittest
import sys
import os
import json

# Add scripts directory to path so we can import web_dashboard
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from web_dashboard import app

class TestWebDashboard(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_dashboard_route(self):
        """Test that the root route returns HTML."""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'<!DOCTYPE html>', response.data)
        self.assertIn(b'MQL5 Trading Automation Dashboard', response.data)

    def test_health_route_json(self):
        """Test that the health route returns a JSON response."""
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)

        # This is what we expect AFTER the optimization.
        # For TDD, this test will fail initially if I ran it now against the current code
        # (because current code returns HTML for /health).
        try:
            data = json.loads(response.data)
            self.assertEqual(data.get('status'), 'healthy')
        except json.JSONDecodeError:
            self.fail("Response is not valid JSON")

    def test_skip_link_present(self):
        """Test that the skip link is present in the dashboard HTML."""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'<a href="#status" class="skip-link">Skip to main content</a>', response.data)

    def test_security_headers(self):
        """Test that security headers are present."""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn('Content-Security-Policy', response.headers)
        self.assertIn('X-Content-Type-Options', response.headers)
        self.assertIn('X-Frame-Options', response.headers)
        self.assertIn('Referrer-Policy', response.headers)

    def test_error_handling_no_leak(self):
        """Test that exceptions do not leak internal details."""
        from unittest.mock import patch
        # Patch get_cached_markdown to raise an exception with sensitive info
        with patch('web_dashboard.get_cached_markdown', side_effect=Exception("SENSITIVE_INTERNAL_INFO")):
            response = self.app.get('/')

            # Should return 500
            self.assertEqual(response.status_code, 500)

            # Should NOT contain the sensitive info
            self.assertNotIn(b'SENSITIVE_INTERNAL_INFO', response.data)

            # Should contain generic error message
            self.assertIn(b'Internal Server Error', response.data)

if __name__ == '__main__':
    unittest.main()
