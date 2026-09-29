# Alert decision contract

يعيد `POST /v1/analysis/behavioral` بالإضافة إلى نتيجة الخطر قرار التنبيه:

| الحقل | الوصف |
|---|---|
| `should_create_alert` | `true` فقط عند مستوى `high` |
| `alert_severity` | `warning` عند الخطر العالي، و`info` خلاف ذلك |
| `alert_title` | عنوان جاهز للحفظ عند الحاجة |
| `alert_message` | رسالة جاهزة للمستخدم والطبيب عند الحاجة |

عند `high` تكون الرسالة: `Behavioral pattern needs review` مع توضيح أن تغيرات متكررة في المزاج أو النوم أو النشاط تحتاج مراجعة مع فريق الرعاية.

هذا القرار لا يرسل إشعارًا أو ينشئ مستندًا وحده. طبقة Firebase الموثقة يجب أن تتحقق من هوية المستخدم ثم تحفظ النتيجة في `risk_assessments` وتنشئ مستندًا في `alerts` مع `userId` و`createdAt`، مع منع تكرار التنبيه لنفس يوم التقييم.
