# تنفيذ لوحة المستخدم والمعالج

تم تنفيذ أول نسخة تشغيلية من شاشات لوحة التحكم وفق مرجع Figma.

## Patient Home

تحتوي الشاشة على هوية Life Pattern، تحية المستخدم، بطاقة Behavioral change score، بطاقات Sleep وActivity وMood وAlerts، مخطط آخر سبعة أيام، وزر Add daily check-in.

## Doctor Patients

تحتوي الشاشة على هوية Life Pattern، وصف موجز للقائمة، المرضى المتصلين، حالة كل مريض، ومؤشر Review needed للحالات التي تحتاج متابعة.

## التنقل

تمت إضافة شريط تنقل سفلي بخمس وجهات. تختلف الوجهات حسب الدور:

- Patient: Home، History، Alerts، Reports، Profile.
- Doctor: Patients، Messages، Alerts، Reports، Profile.

## حدود التنفيذ الحالي

البيانات المعروضة حاليًا بيانات واجهة تجريبية منظمة لتثبيت التصميم والتدفق. لم يتم ربطها بعد ببيانات `behavioral_data` أو `risk_assessments` أو `patient_therapist_links` في Firestore. هذه الخطوة تأتي بعد اعتماد مخطط قاعدة البيانات وقواعد الأمان.
