# Scheduled daily analysis

تم اعتماد تشغيل التحليل اليومي من داخل استضافة التطبيق. نقطة التشغيل هي:

```text
POST /v1/jobs/daily-analysis
Header: X-Analysis-Key: <ANALYSIS_INTERNAL_KEY>
```

المهمة تقرأ مستخدمي Patient من Firestore، ثم تقرأ آخر سبعة سجلات يومية لكل مريض، وتحولها إلى ملاحظات تحليل، وتستدعي `run_daily_analysis`. عند وجود مستوى خطر عالٍ تحفظ Risk Assessment وتنشئ Alert بمعرّف ثابت.

يجب تسجيل هذه النقطة في جدولة الاستضافة مرة واحدة يوميًا بعد وقت اكتمال إدخالات المرضى. لا ينبغي تشغيلها من تطبيق الهاتف، ولا وضع المفتاح في Flutter. إذا لم تُضبط Firebase Admin أو `ANALYSIS_INTERNAL_KEY` يعيد endpoint خطأ إعداد بدل تنفيذ جزئي.

للاختبار الداخلي فقط:

```bash
curl -X POST "$APP_URL/v1/jobs/daily-analysis" \
  -H "X-Analysis-Key: $ANALYSIS_INTERNAL_KEY"
```

الاستجابة المتوقعة تتضمن `status: completed` وعدد `processed` و`skipped`، دون إعادة بيانات المرضى أو الأسرار.
