# Messaging وPatient-Therapist Links

## روابط المرضى بالمعالجين

تحفظ العلاقة في:

```text
patient_therapist_links/{patientId}_{doctorId}
```

وتتضمن `patientId` و`doctorId` و`status` و`createdAt`.

## الرسائل

تحفظ الرسائل في مجموعة:

```text
messages/{messageId}
```

وتتضمن `senderId` و`recipientId` و`text` و`read` و`createdAt`.

يقرأ الطبيب صندوق رسائله عبر استعلام `recipientId`. ويستطيع الطرف المستقبل تعليم الرسالة كمقروءة. قواعد Firestore تقصر القراءة على المرسل أو المستقبل، وتمنع تحديث الرسالة إلا من المستقبل.

## المرحلة الحالية

تم ربط شاشة Doctor Messages ببيانات Firestore الحقيقية. إرسال الرسائل وواجهة محادثة تفصيلية سيُضافان بعد تنفيذ اختيار المريض من Doctor Patients وتأكيد رابط المريض بالمعالج من الطرفين.
