# إعداد Firebase والمصادقة

## خيارات تسجيل الدخول المعتمدة

المشروع يعتمد الخيارين معًا:

1. البريد الإلكتروني وكلمة المرور.
2. Google Sign-In.

تمت إضافة حزم `firebase_core` و`firebase_auth` و`google_sign_in` و`cloud_firestore` إلى تطبيق Flutter، كما أضيفت خدمة `AuthService` التي تفصل منطق المصادقة عن الواجهات.

## المطلوب من مالك المشروع

أنشئ مشروعًا جديدًا في Firebase Console، ثم فعّل من Authentication → Sign-in method:

- Email/Password.
- Google.

بعد ذلك أضف تطبيق Android وتطبيق iOS داخل مشروع Firebase، ثم نزّل:

- `google-services.json` وضعه في `mobile_app/android/app/`.
- `GoogleService-Info.plist` وضعه في `mobile_app/ios/Runner/`.

للدعم الكامل على الويب، نحتاج أيضًا إعداد Web App من Firebase Console وقيم Firebase Web configuration. لا تضع مفاتيح Service Account داخل المستودع أو ZIP.

## الربط المحلي

بعد وضع ملفات Firebase:

```bash
cd mobile_app
flutter pub get
flutter analyze
flutter test
flutter run
```

إذا استخدمنا FlutterFire CLI لاحقًا، يمكن توليد `lib/firebase_options.dart` تلقائيًا، مع إبقاء الملف خارج المشاركة العامة إذا احتوى على إعدادات خاصة بالمشروع.

## قواعد أمان

لا تُرسل Service Account JSON في المحادثة. لا تُضمّن كلمات المرور أو مفاتيح الخادم في التطبيق. بيانات المستخدمين والموافقات والتنبيهات يجب أن تُحمى بقواعد Firestore بعد مراجعة مخطط قاعدة البيانات في المرحلة التالية.
