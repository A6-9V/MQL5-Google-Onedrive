import unittest
from unittest.mock import patch, MagicMock
import sys
import os

# Add scripts directory to path so we can import web_dashboard
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from web_dashboard import app

class TestWebDashboardSecurity(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    @patch('web_dashboard.get_cached_markdown')
    def test_error_handling_leak(self, mock_get_cached_markdown):
        """
        Test that exceptions do not leak internal details to the user.
        Currently, the app returns the exception string, which is a vulnerability.
        """
        # Mock an exception with sensitive info
        sensitive_info = "SecretDBPassword123"
        mock_get_cached_markdown.side_effect = Exception(f"Connection failed: {sensitive_info}")

        response = self.app.get('/')

        # We assert that the status is 500
        self.assertEqual(response.status_code, 500)

        # In a secure app, the sensitive info is suppressed
        response_text = response.get_data(as_text=True)

        # Verify sensitive info is NOT leaked
        self.assertNotIn(sensitive_info, response_text, "Exception message leaked to user response!")

        # Verify generic error message is returned
        self.assertIn("Internal Server Error", response_text)
        print("\n[SECURE] Exception message successfully suppressed.")

if __name__ == '__main__':
    unittest.main()
