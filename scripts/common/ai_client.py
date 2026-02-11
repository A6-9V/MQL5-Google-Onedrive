"""
Shared AI client for Gemini and Jules APIs.
Reduces duplication of API integration code.
"""

import os
import logging
import requests
import warnings
from typing import Optional

# Suppress deprecation warnings from google.generativeai
warnings.filterwarnings("ignore", category=UserWarning, module="google.generativeai")

logger = logging.getLogger(__name__)


class GeminiClient:
    """Client for Google Gemini API."""
    
    def __init__(
        self,
        api_key: Optional[str] = None,
        model: Optional[str] = None
    ):
        """
        Initialize Gemini client.
        
        Args:
            api_key: Gemini API key (defaults to GEMINI_API_KEY or GOOGLE_API_KEY env var)
            model: Model name (defaults to GEMINI_MODEL env var or 'gemini-2.0-flash')
        """
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
        self.model_name = model or os.environ.get("GEMINI_MODEL", "gemini-2.0-flash")
        self._model = None
    
    def is_available(self) -> bool:
        """Check if Gemini is available (API key present)."""
        return self.api_key is not None
    
    def generate(self, prompt: str) -> Optional[str]:
        """
        Generate content using Gemini.
        
        Args:
            prompt: Text prompt for generation
        
        Returns:
            Generated text or None if error
        """
        if not self.is_available():
            logger.warning("Gemini API key not found. Set GEMINI_API_KEY or GOOGLE_API_KEY.")
            return None
        
        try:
            # Lazy import to avoid dependency issues
            import google.generativeai as genai
            
            genai.configure(api_key=self.api_key)
            
            if self._model is None:
                self._model = genai.GenerativeModel(self.model_name)
            
            response = self._model.generate_content(prompt)
            return response.text
        except Exception as e:
            logger.error(f"Gemini API request failed: {e}")
            return None


class JulesClient:
    """Client for Jules API."""
    
    def __init__(
        self,
        api_key: Optional[str] = None,
        api_url: Optional[str] = None,
        model: Optional[str] = None
    ):
        """
        Initialize Jules client.
        
        Args:
            api_key: Jules API key (defaults to JULES_API_KEY env var)
            api_url: Jules API URL (defaults to JULES_API_URL env var)
            model: Model name (defaults to JULES_MODEL env var or 'jules-v1')
        """
        self.api_key = api_key or os.environ.get("JULES_API_KEY")
        self.api_url = api_url or os.environ.get("JULES_API_URL")
        self.model = model or os.environ.get("JULES_MODEL", "jules-v1")
    
    def is_available(self) -> bool:
        """Check if Jules is available (API key and URL present)."""
        return self.api_key is not None and self.api_url is not None
    
    def generate(self, prompt: str, timeout: int = 60) -> Optional[str]:
        """
        Generate content using Jules.
        
        Args:
            prompt: Text prompt for generation
            timeout: Request timeout in seconds (default: 60)
        
        Returns:
            Generated text or None if error
        """
        if not self.is_available():
            if not self.api_key:
                logger.warning("Jules API key not found. Set JULES_API_KEY.")
            if not self.api_url:
                logger.warning("Jules API URL not found. Set JULES_API_URL.")
            return None
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        payload = {
            "model": self.model,
            "prompt": prompt
        }
        
        try:
            response = requests.post(
                self.api_url,
                json=payload,
                headers=headers,
                timeout=timeout
            )
            response.raise_for_status()
            
            # Parse response - handle different response formats
            try:
                resp_json = response.json()
                
                # Try different response formats
                if "response" in resp_json:
                    return resp_json["response"]
                elif "choices" in resp_json and len(resp_json["choices"]) > 0:
                    return resp_json["choices"][0].get("text", str(resp_json))
                else:
                    return str(resp_json)
            except ValueError:
                # Response is not JSON
                return response.text
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Jules API request failed: {e}")
            return None


def create_ai_clients() -> tuple[GeminiClient, JulesClient]:
    """
    Create and return both AI clients.
    
    Returns:
        Tuple of (GeminiClient, JulesClient)
    """
    return GeminiClient(), JulesClient()


def ask_gemini(prompt: str, api_key: Optional[str] = None, model: Optional[str] = None) -> Optional[str]:
    """
    Convenience function to query Gemini.
    
    Args:
        prompt: Text prompt
        api_key: Optional API key override
        model: Optional model name override
    
    Returns:
        Generated text or None
    """
    client = GeminiClient(api_key=api_key, model=model)
    return client.generate(prompt)


def ask_jules(prompt: str, api_key: Optional[str] = None, api_url: Optional[str] = None, model: Optional[str] = None) -> Optional[str]:
    """
    Convenience function to query Jules.
    
    Args:
        prompt: Text prompt
        api_key: Optional API key override
        api_url: Optional API URL override
        model: Optional model name override
    
    Returns:
        Generated text or None
    """
    client = JulesClient(api_key=api_key, api_url=api_url, model=model)
    return client.generate(prompt)
