# Design brief — Life Pattern System

## Ground-truth reference

المرجع البصري المعتمد هو صورة Figma المرسلة: **Life Pattern — English editable screens**. لا توجد حرية لاستبدال الاتجاه البصري؛ التنفيذ اللاحق يجب أن يطابق المرجع.

## الاتجاه البصري

- واجهة جوال عمودية باللغة الإنجليزية في المرجع الحالي.
- خلفية فاتحة جدًا وقريبة من الأبيض.
- أخضر داكن للهوية والعناوين والأزرار الأساسية.
- بطاقات بيضاء بحدود خفيفة وحواف ناعمة.
- ظلال خفيفة جدًا، دون زخارف أو صور كبيرة.
- لون برتقالي/أصفر للتنبيهات والتحليل، وألوان دلالية للنشاط والنوم والتنبيهات.
- شريط تنقل سفلي ثابت بخمس وجهات تقريبية: Home، History، Alerts، Reports، Profile.
- رسوم خطية وأعمدة بسيطة لعرض الاتجاهات.
- تصميم portrait مناسب للاستخدام بيد واحدة.
- النصوص قصيرة وواضحة، والهوية هادئة وغير تشخيصية.

## الشاشات المرجعية

1. Sign in: شعار Life Pattern، البريد، كلمة المرور، زر Sign in، رابط إنشاء حساب.
2. Create account: البريد، كلمة المرور، نوع الحساب Patient/Doctor، زر Create account.
3. Patient home: ترحيب بالمستخدم، درجة التغير السلوكي، بطاقات Sleep/Activity/Mood/Alerts، مخطط آخر 7 أيام، زر Daily check-in.
4. History: مخطط خطي مع markers، وسجل Daily check-in.
5. Reports: بطاقة Behavioral analysis، مخطط تاريخي، بطاقة Progress analysis.
6. Patient profile: بيانات المستخدم، Connected devices، Edit profile، Language، Privacy.
7. Connected devices: Garmin Band 3، Fitbit، Apple S8+، FitHealth، حالات Connected/Connect، زر Save.
8. Daily check-in: Mood، Sleep quality، Notes، زر Save.
9. Doctor patients: قائمة المرضى مع حالات Connected وتدرجات لونية للأولوية.
10. Doctor messages: رسائل وملاحظات متابعة المرضى.
11. Doctor profile: بيانات الطبيب، Connected devices، Edit profile، Language، Privacy.

## مكونات مشتركة

- App header مع اسم Life Pattern وأيقونة إعدادات/مساعدة.
- بطاقة معلومات مستديرة الحواف.
- زر أخضر أساسي بعرض كبير.
- حقول إدخال بسيطة.
- مؤشر خطر ملون.
- Bottom navigation حسب الدور.
- Empty/loading/error states متوافقة مع الهوية.

## ملاحظة تنفيذية

المرجع الحالي باللغة الإنجليزية. لن تتم إضافة ترجمة أو تغيير نصوص الواجهات في هذه المرحلة إلا بقرار موثق لاحقًا؛ دعم RTL والعربية يظل مطلبًا وظيفيًا لاحقًا عند تحديد لغة التسليم.
