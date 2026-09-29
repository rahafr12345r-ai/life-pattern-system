"""Lazy Firebase Admin initialization for server-only persistence."""

import os

import firebase_admin
from firebase_admin import credentials, firestore


def get_firestore_client():
    if not firebase_admin._apps:
        credential_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        project_id = os.getenv("FIREBASE_PROJECT_ID")
        options = {"projectId": project_id} if project_id else None
        credential = credentials.Certificate(credential_path) if credential_path else credentials.ApplicationDefault()
        firebase_admin.initialize_app(credential, options=options)
    return firestore.client()
