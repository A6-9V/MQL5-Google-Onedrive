import unittest
import unittest.mock
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

    @unittest.mock.patch('web_dashboard.render_template_string')
    def test_error_leakage(self, mock_render):
        """Test that exceptions do not leak stack traces."""
        # Force an error
        mock_render.side_effect = Exception("Sensitive internal info")

        response = self.app.get('/')

        # Verify status code is 500
        self.assertEqual(response.status_code, 500)

        # Verify we don't see the sensitive info
        self.assertNotIn(b"Sensitive internal info", response.data)

        # Verify we see a generic error
        self.assertIn(b"Internal Server Error", response.data)

if __name__ == '__main__':
    unittest.main()
