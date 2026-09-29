# Runtime readiness

تمت إضافة endpoint:

```text
GET /health/config
```

يعيد فقط مؤشرات منطقية لوجود إعدادات Firebase Admin ومفتاح التحليل الداخلي، ولا يعيد قيمة المشروع الحساسة أو مسار Service Account أو المفتاح نفسه.

مثال:

```json
{
  "firebase_project_configured": true,
  "firebase_credentials_configured": true,
  "analysis_key_configured": true
}
```

يُستخدم هذا الفحص في بيئة الخادم فقط قبل تشغيل مهمة التحليل. لا ينبغي عرضه في تطبيق الهاتف أو استخدامه بدل مصادقة المستخدم.
