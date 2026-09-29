# عقد بيانات لوحات التحكم

## Patient Home

تقرأ اللوحة أحدث مستند من:

```text
behavioral_data/{userId}/daily/{dayId}
```

الحقول المدعومة حاليًا:

| الحقل | النوع | الاستخدام |
|---|---|---|
| `sleepHours` | number | بطاقة النوم |
| `activitySteps` | number | بطاقة النشاط |
| `mood` | string | بطاقة المزاج |
| `alertCount` | number | بطاقة التنبيهات |
| `riskScore` | number | درجة التغير السلوكي |
| `date` | timestamp/string | ترتيب أحدث سجل |

عند عدم وجود سجل يومي، تعرض الواجهة حالة فارغة ولا تعرض أرقامًا تجريبية.

## Doctor Patients

تقرأ اللوحة مستندات المستخدمين ذات الدور Patient من:

```text
users
```

الحقول الحالية:

- `displayName`
- `email`
- `role`
- `patientStatus`

## ملاحظة أمنية

لا تُنشر قواعد `firestore.rules` قبل مراجعتها في Firebase Console واختبارها في Firebase Rules Playground. القواعد المرفقة هي نقطة بداية للمرحلة الحالية، وستتوسع عند إضافة روابط المرضى بالمعالجين والملاحظات السريرية والموافقات التفصيلية.
