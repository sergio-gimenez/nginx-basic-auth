import os
import unittest
from fastapi.testclient import TestClient
from auth_backend import app

client = TestClient(app)


class TestAuthenticate(unittest.TestCase):
    def test_authenticate(self):
        response = client.post(
            "/auth", headers={"Authorization": "Basic Ym9iOnRlc3Q="})
        print(response.json())
        self.assertEqual(response.status_code, 200)
