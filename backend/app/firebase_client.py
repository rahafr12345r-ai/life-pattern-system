"""Lazy Firebase Admin initialization for server-only persistence."""

import os
import json

import firebase_admin
from firebase_admin import credentials, firestore


def get_firestore_client():
    if not firebase_admin._apps:
        credential_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        credential_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
        project_id = os.getenv("FIREBASE_PROJECT_ID")
        options = {"projectId": project_id} if project_id else None
        if credential_json:
            credential = credentials.Certificate(json.loads(credential_json))
        elif credential_path:
            credential = credentials.Certificate(credential_path)
        else:
            credential = credentials.ApplicationDefault()
        firebase_admin.initialize_app(credential, options=options)
    return firestore.client()
