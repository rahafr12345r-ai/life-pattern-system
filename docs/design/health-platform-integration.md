# Health Connect وApple Health

تمت إضافة حزمة `health` وطبقة `HealthDataService` موحّدة لطلب قراءة الخطوات والنوم من Google Health Connect على Android وApple HealthKit على iOS.

عند ضغط Connect على Health Connect أو Apple Watch، يطلب التطبيق أذونات القراءة. بعد قبول الأذونات يقرأ آخر 24 ساعة، ثم يحفظ ملخصًا في:

```text
behavioral_data/{userId}/daily/{YYYY-MM-DD}
```

ويحفظ `activitySteps` و`sleepHours` مع `source: health_platform`. لا يتم طلب أو حفظ بيانات قلبية أو معلومات طبية حساسة في هذه المرحلة.

## متطلبات التشغيل الفعلي

على Android يجب تثبيت Health Connect وإضافة أذونات الخطوات والنوم وActivity Recognition. على iOS يجب تفعيل HealthKit capability من Xcode على Runner، مع وجود iOS 15 أو أحدث. لا يمكن اختبار نافذة الأذونات وقراءة البيانات في Sandbox Linux؛ يلزم جهاز Android أو iPhone حقيقي.

إذا رفض المستخدم الأذونات، لا تُحفظ حالة اتصال الجهاز وتظهر رسالة واضحة. التطبيق لا يقرأ إلا الفئات التي وافق عليها المستخدم.
