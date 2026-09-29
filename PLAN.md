# خطة بناء نظام النمط الحياتي

## القرار التقني المعتمد

هذا المشروع يلتزم حرفيًا بالتقرير:

- تطبيق الهاتف ولوحة المعالج: Flutter وDart.
- الواجهة الخلفية: Python وFastAPI.
- قاعدة البيانات والمصادقة: Firebase Firestore وFirebase Authentication.
- التحليل السلوكي: Python rule-based analysis.
- الإشعارات: Firebase Cloud Messaging.
- البيانات الصحية: HealthKit وHealth Connect.
- التحكم بالإصدارات: Git وGitHub.
- الاختبارات: يدوي، وحدة، وظيفي.

## مراحل التنفيذ

1. إعداد البيئة وهيكل المشروع.
2. إعداد Firebase والمصادقة وقواعد Firestore.
3. بناء FastAPI وربطه بـ Firebase.
4. بناء محرك خط الأساس والتحليل وفق قواعد التقرير.
5. تنفيذ واجهات Flutter للمستخدم ولوحة المعالج وفق Figma.
6. دمج FCM وHealthKit وHealth Connect.
7. التكامل والاختبارات.
8. التوثيق والعرض النهائي.

## المرحلة الحالية

المرحلة 1 فقط: إنشاء الهيكل، ملفات الإعداد، التوثيق الأولي، وجرد شاشات Figma. لا يتم اعتبار Firebase أو API أو التحليل أو الواجهات الوظيفية مكتملة قبل تأكيد المرحلة الحالية.

## قيد البيئة

Flutter وDart غير مثبتين في Sandbox الحالية. لذلك تم إنشاء الهيكل وملفات البداية يدويًا بصورة متوافقة مع Flutter، وسيتم تشغيل `flutter create` و`flutter pub get` و`flutter analyze` بعد توفير Flutter SDK في بيئة التطوير. لم يتم استبدال Flutter بـ Expo أو React Native.
