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

    def test_security_headers(self):
        """Test that security headers are present."""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

        # Check for Security Headers
        self.assertIn('Content-Security-Policy', response.headers)
        self.assertIn('X-Content-Type-Options', response.headers)
        self.assertIn('X-Frame-Options', response.headers)
        self.assertIn('Referrer-Policy', response.headers)

        # Validate specific values
        self.assertEqual(response.headers['X-Content-Type-Options'], 'nosniff')
        self.assertEqual(response.headers['X-Frame-Options'], 'SAMEORIGIN')
        self.assertEqual(response.headers['Referrer-Policy'], 'strict-origin-when-cross-origin')

        # Check CSP content
        csp = response.headers['Content-Security-Policy']
        self.assertIn("default-src 'self'", csp)
        self.assertIn("script-src 'self'", csp)

if __name__ == '__main__':
    unittest.main()
