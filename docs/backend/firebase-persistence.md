# Firebase persistence

تمت إضافة `firebase_persistence.py` لبناء وحفظ مستندات التحليل في مسارين ثابتين:

```text
risk_assessments/{userId}/daily/{YYYY-MM-DD}
alerts/{userId}_{YYYY-MM-DD}_behavioral_review
```

النتيجة عالية الخطورة تنشئ مستند Alert بمعرّف ثابت، لذلك تكرار تشغيل التحليل في اليوم نفسه يحدّث المستند نفسه ولا ينشئ تنبيهات مكررة. النتيجة المنخفضة أو المتوسطة تحفظ Risk Assessment فقط.

طبقة الحفظ تستقبل Firestore client بالحقن، وهذا يجعلها قابلة للاختبار دون بيانات اعتماد. قبل تشغيلها في البيئة المنشورة يجب تهيئة Firebase Admin باستخدام Service Account آمن، والتحقق من هوية المستخدم في طبقة API قبل تمرير `userId` إلى الحفظ.
