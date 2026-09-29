# History وReports وProfile

تم ربط History وReports بسجلات `behavioral_data/{userId}/daily` في Firestore.

- History يعرض آخر 30 تسجيلًا يوميًا مع المزاج وجودة النوم والملاحظات والتاريخ.
- Reports يعرض ملخصًا لعدد التسجيلات ومتوسط جودة النوم، ثم تفاصيل السجلات.
- Profile يعرض بيانات الملف وقسم Connected devices وEdit profile وLanguage وPrivacy كواجهات جاهزة للتوسعة.
- عند عدم وجود بيانات، تظهر رسالة واضحة تطلب إكمال أول Daily check-in بدل عرض بيانات وهمية.
