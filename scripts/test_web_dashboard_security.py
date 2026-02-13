import unittest
from unittest.mock import patch
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from web_dashboard import app

class TestWebDashboardSecurity(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    @patch('web_dashboard.get_cached_markdown')
    def test_error_handling_no_leak(self, mock_get_cached_markdown):
        """Test that exceptions are handled gracefully without leaking details."""
        # Simulate an unexpected error with sensitive info
        secret = "Secret Database Path: /etc/passwd"
        mock_get_cached_markdown.side_effect = Exception(secret)

        response = self.app.get('/')

        # Expect 500 Internal Server Error
        self.assertEqual(response.status_code, 500)

        # Expect generic error message
        self.assertIn(b"Internal Server Error", response.data)

        # Expect sensitive info NOT to be present
        self.assertNotIn(b"Secret Database Path", response.data)
        self.assertNotIn(b"/etc/passwd", response.data)

if __name__ == '__main__':
    unittest.main()
