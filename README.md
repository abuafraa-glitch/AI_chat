# Hajeen AI — Flutter Core

## وصف المشروع

هذا المستودع يحتوي على نواة تطبيق Flutter لمنصة Hajeen AI: واجهة محادثة مع نماذج ذكاء اصطناعي، إدارة محادثات وملفات، وإعدادات وميزات حساب واشتراكات جاهزة داخليًا للانتقال اللاحق إلى تكامل Backend.

## حالة المشروع الحالية

المشروع حاليًا **Flutter Core Project** بلا مجلدات منصات. تم الاحتفاظ بكود التطبيق وملفات الأصول والاختبارات والعقود الداخلية فقط. ستتم إضافة Android وiOS وWeb وWindows وmacOS وLinux لاحقًا دفعة واحدة.

**حالة Backend:** غير مربوط حاليًا. لا يوجد Backend أو Mock Server أو بيانات تجريبية داخل هذا المستودع.

## المعمارية الحالية

المسار المعماري الأساسي هو:

> `UI → Cubit/BLoC/Controller → Repository → RemoteDataSource → ApiConsumer → API Endpoint`

تستخدم المصادقة `AuthController` خلف `AuthRepository`، وتستخدم الميزات الأخرى Cubits مع Repositories مسجلة في GetIt. التخزين المحلي والآمن والخدمات التقنية تعمل من خلال طبقة الخدمات وDataSources المحلية، بينما تبقى API Contracts معرفة للاستعداد للتكامل اللاحق.

## المجلدات الرئيسية

| المجلد/الملف | الغرض |
|---|---|
| `lib/` | كود التطبيق: Core وData وPresentation والتوطين والتوجيه |
| `assets/` | الخطوط والصور والأيقونات والرسوم والترجمات المستخدمة في التطبيق |
| `test/` | اختبارات الوحدات والـ Cubits والنماذج والشبكة والواجهات |
| `pubspec.yaml` | تعريف المشروع والاعتماديات |
| `pubspec.lock` | تثبيت إصدارات الاعتماديات |
| `analysis_options.yaml` | إعدادات Dart/Flutter analyzer |
| `README.md` | وثيقة المشروع الرئيسية |

## الميزات الموجودة فعليًا

| المجال | الحالة الحالية |
|---|---|
| Authentication | تسجيل الدخول وإنشاء الحساب وتحقق البريد وإعادة الإرسال ونسيت/إعادة تعيين كلمة المرور وإدارة الجلسة وتحديث Token وتسجيل الخروج عبر AuthController وAuthRepository |
| User Profile | قراءة بيانات المستخدم عبر `ProfileCubit → UserRepository → RemoteDataSource → GET /users/me` |
| Chat | قائمة المحادثات، فتح محادثة، إرسال رسالة، استقبال الرد، Streaming/SSE، وإعادة توليد الرد عبر MessageRepository |
| AI Models | تحميل كتالوج النماذج واختيار النموذج عبر ModelsCubit وAIRepository |
| Conversations | عرض وإنشاء وتعديل عنوان وحذف المحادثات، والبحث في المحادثات |
| Files | عرض ورفع وحذف الملفات عبر FilesCubit وFileRepository |
| Notifications | عرض قائمة الإشعارات عبر NotificationsCubit وNotificationRepository |
| Agents | عرض قائمة الوكلاء عبر AgentsCubit وAgentRepository |
| Subscriptions | عرض خطط الاشتراك والاشتراك الحالي عبر SubscriptionsCubit وSubscriptionRepository، دون تنفيذ شراء فعلي |
| Payments | عرض سجل المدفوعات عبر PaymentsCubit وPaymentRepository، دون Checkout أو Payment Confirmation |
| Settings | تغيير اللغة والمظهر وإدارة التفضيلات محليًا |
| Routing | GoRouter مع Auth Guards وFeature Flags وStateful Shell للتبويبات |
| حالات الواجهة | Loading وEmpty وError states حسب استجابة المسارات المتاحة |

## الميزات الجزئية

الميزات التالية لها جزء داخلي موجود لكن لم تكتمل كوظائف مستخدم نهائية: Google Sign-In وFacebook Login بحسب إعدادات SDK، حذف الرسائل، البحث العام، إلغاء الاشتراك، عمليات Agent CRUD وRuns، إجراءات قراءة الإشعارات، وعمليات Payment Intent/Checkout/Confirmation.

## Backend Contracts غير المنفذة كميزات

توجد عقود ومسارات API دون شاشة أو State أو مسار مستخدم مكتمل لبعض العمليات، ومنها تعديل الملف الشخصي وتغيير كلمة المرور وحذف الحساب ورفع Avatar، وتنزيل الملفات والبحث في الملفات، وAgent CRUD وRuns، وMark Notification as Read/Read All، وRAG Documents وRAG Query، وPayment Intent وعمليات الدفع النهائية، إضافة إلى Health endpoint.

وجود Endpoint أو Model لا يعني أن الميزة متاحة للمستخدم أو أن Backend يعمل. هذه العناصر محفوظة كـ contracts تمهيدًا للتكامل اللاحق.

## الميزات غير الموجودة

لا توجد حاليًا شاشة Checkout مستقلة، ولا شاشة تأكيد دفع، ولا واجهة RAG/Knowledge Base، ولا واجهات كاملة لتعديل الملف الشخصي أو تغيير كلمة المرور أو حذف الحساب أو إدارة Avatar. كما لا توجد واجهات Agent CRUD/Runs أو إجراءات إشعارات Mark as Read.

## Local فقط

تغيير المظهر واللغة، حالة إكمال Onboarding، التخزين المحلي، التخزين الآمن للجلسة والتوكنات، التوجيه وحراسة المسارات، وحالات العرض العامة لا تحتاج Backend بذاتها. أما Cache المحادثات وبعض بيانات الجلسة فتبقى محلية ضمن حدود استخدامها الحالي ولا تمثل بيانات Backend بديلة.

## المنصات

لا يحتوي المستودع حاليًا على `android/` أو `ios/` أو `web/` أو `windows/` أو `macos/` أو `linux/`. ستتم إضافة هذه المنصات لاحقًا دفعة واحدة كما هو مخطط.

## آخر حالة للتحقق

تم تنفيذ التحقق على نسخة المشروع قبل تنظيف المنصات والتوثيق:

| الأمر | النتيجة |
|---|---|
| `flutter pub get` | نجح |
| `flutter analyze` | اكتمل مع 259 issue: صفر أخطاء، 11 warning، و248 info |
| `flutter test` | نجح، مع 93 اختبارًا ناجحًا |
| `flutter build web --release` | نجح سابقًا قبل حذف مجلد Web عمدًا |
| `git diff --check` | نجح في آخر تحقق للتعديلات البرمجية السابقة |

لم يتم إصلاح ملاحظات analyzer في عملية تنظيف المستودع الحالية، ولم يتم تغيير `lib/` أو `assets/` أو `test/`.

## نطاق هذه المرحلة

هذه المرحلة مخصصة لتنظيف بنية المستودع فقط. لا تشمل Backend Integration أو حذف Dead Code أو استكمال الميزات أو تعديل API Contracts أو إضافة Mock/Fake/Dummy data.
