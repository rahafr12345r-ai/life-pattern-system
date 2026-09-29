# Firebase Admin setup

تمت إضافة تهيئة Firebase Admin الكسولة عبر `firebase_client.py`. لا يتم تحميل Service Account عند استيراد التطبيق، بل عند استدعاء endpoint الحفظ فقط.

المتغيرات المطلوبة في بيئة الخادم هي:

```text
FIREBASE_PROJECT_ID=life-pattern-system-f72f8
GOOGLE_APPLICATION_CREDENTIALS=/secure/path/firebase-service-account.json
ANALYSIS_INTERNAL_KEY=<long-random-secret>
```

الملف JSON يجب أن يبقى خارج المستودع، وألا يدخل ZIP أو Git. endpoint الحفظ هو:

```text
POST /v1/analysis/behavioral/persist
Header: X-Analysis-Key: <ANALYSIS_INTERNAL_KEY>
```

بدون المفتاح يعيد الخادم `503` لأن الحفظ غير مهيأ. بالمفتاح الخاطئ يعيد `401`. عند نجاح التحقق يستدعي الخط تحليل البيانات ثم يحفظ Risk Assessment وAlert idempotently.

هذا المفتاح مخصص لمهمة داخلية موثوقة فقط، وليس لتطبيق الهاتف. قبل النشر يجب وضعه في Secret Manager أو متغيرات بيئة المنصة، وإضافة Firebase App Check أو مصادقة خدمة داخلية أقوى إذا كان endpoint سيُعرض خارج الشبكة الموثوقة.
