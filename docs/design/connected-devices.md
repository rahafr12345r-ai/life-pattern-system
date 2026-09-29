# Connected devices

تم تنفيذ شاشة Connected devices وربطها من Profile للمستخدم الحالي.

تحفظ حالة كل جهاز في:

```text
users/{userId}/connected_devices/{deviceId}
```

الأجهزة المعروضة كبداية هي Garmin Band 8 وFitbit وApple Watch وHealth Connect. لكل جهاز زر Connect أو Disconnect، وتُحفظ الحالة في Firestore مع وقت آخر تحديث.

هذه المرحلة تدير حالة الربط داخل التطبيق. التكامل الفعلي مع APIs الخاصة بـ Fitbit وHealth Connect وApple Health يحتاج إعدادًا خاصًا بكل منصة وأذونات النظام، وسيُنفذ بعد تحديد الأجهزة المستهدفة واختبار التطبيق على Android وiOS حقيقيين.
