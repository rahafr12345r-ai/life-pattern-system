# Scheduler runbook

يوجد سكربت تشغيل جاهز في:

```text
backend/scripts/run_daily_analysis.sh
```

السكربت يتطلب متغيرين فقط من مخزن الأسرار في جدولة الاستضافة:

```text
APP_URL=https://api.example.com
ANALYSIS_INTERNAL_KEY=<secret>
```

ويستدعي:

```text
POST /v1/jobs/daily-analysis
```

يجب جدولة التشغيل مرة واحدة يوميًا بعد انتهاء فترة إدخال Daily check-in، مثل 02:00 بالتوقيت المحلي. عند غياب أي متغير يتوقف السكربت قبل الاتصال. لا يُحفظ المفتاح في Git أو ملف `.env` داخل المشروع، ولا يتم تضمينه في تطبيق الهاتف.

مثال تشغيل محلي آمن بعد ضبط المتغيرات في جلسة مؤقتة:

```bash
APP_URL="https://api.example.com" \
ANALYSIS_INTERNAL_KEY="$ANALYSIS_INTERNAL_KEY" \
./backend/scripts/run_daily_analysis.sh
```

في بيئة الاستضافة، استخدم وظيفة HTTP مجدولة تستدعي نفس endpoint، أو شغّل السكربت كخطوة مجدولة إذا كانت المنصة تدعم سكربتات shell. يجب مراقبة استجابة `status` وعدادَي `processed` و`skipped` دون تسجيل Header المفتاح.
