import unittest
import requests
from bs4 import BeautifulSoup
import os

class WebsiteTest(unittest.TestCase):
    def setUp(self):
        self.website_url = os.environ.get('WEBSITE_URL')
        if not self.website_url:
            self.fail("WEBSITE_URL environment variable not set")
        
    def test_website_title(self):
        response = requests.get(self.website_url)
        self.assertEqual(response.status_code, 200)
        
        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.find('title')
        
        self.assertIsNotNone(title)
        self.assertEqual(title.text, "My Static Website")

if __name__ == '__main__':
    unittest.main()