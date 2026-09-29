# Daily check-in

## الحقول

تحفظ الشاشة السجل اليومي في:

```text
behavioral_data/{userId}/daily/{YYYY-MM-DD}
```

وتكتب:

| الحقل | النوع | الوصف |
|---|---|---|
| `date` | timestamp | وقت الحفظ من الخادم |
| `mood` | string | Good أو Okay أو Low |
| `sleepQuality` | integer | قيمة من 1 إلى 5 |
| `notes` | string | ملاحظات المستخدم |
| `source` | string | `manual_checkin` |
| `updatedAt` | timestamp | آخر تعديل |

## السلوك

- يتم إنشاء سجل واحد لكل يوم.
- إعادة الحفظ في اليوم نفسه تحدث السجل بدل إنشاء سجل مكرر.
- لا تُقرأ الملاحظات أو تُرسل للمعالج ضمن هذه الخطوة؛ مشاركة البيانات التفصيلية تحتاج موافقة وإعدادات منفصلة.
- زر Add daily check-in في Patient Home يفتح الشاشة مباشرة باستخدام UID المستخدم الحالي.
