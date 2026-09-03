# تقرير تجهيز التطبيق للربط مع Backend

تمت مراجعة مشروع Flutter الحالي وتجهيزه للربط المستقبلي مع Backend دون تنفيذ أي اتصال فعلي أثناء هذه المهمة. تم الحفاظ على طبقات Network وRepository وState Management الحالية، ولم تتم إضافة طبقة Integration جديدة أو إعادة بناء المعمارية.

## ما تم تعديله

| الملف | التعديل |
|---|---|
| `lib/core/di/injection.dart` | إزالة اختيار `MockRemoteDataSource` وتسجيل `RemoteDataSourceImpl` الحالي فقط، مع إضافة علامة Backend Integration واضحة |
| `lib/core/config/offline_mode.dart` | كان وضع Offline/Demo مفعّلًا افتراضيًا؛ تم تعطيله افتراضيًا ثم إزالة الملف بعد زوال جميع مراجع التشغيل له |
| `lib/presentation/blocs/auth_controller.dart` | إزالة المصادقة الوهمية، واستعادة مساري `signIn` و`signUp` الحقيقيين، وإضافة علامات الربط لمسارات Login/Register/Google/Facebook/Logout/Password/Email Verification |
| `lib/presentation/screens/login_screen.dart` | إزالة زر ومسار Try demo وبيانات الدخول التجريبية فقط، مع إبقاء واجهة تسجيل الدخول الحقيقية |
| `lib/data/models/subscription_plan_model.dart` | إزالة القيم الافتراضية التجارية للسعر والعملة وجعلهما اختياريين عند غياب Backend |
| `lib/data/models/payment_model.dart` | إزالة القيم الافتراضية التجارية للمبلغ والعملة وجعلهما اختياريين عند غياب Backend |
| `lib/data/datasources/remote/mock_remote_data_source.dart` | حذف مصدر البيانات الوهمي الذي كان يحتوي على مستخدمين ومحادثات ونماذج وخطط ومدفوعات تجريبية |

## الوظائف الجاهزة للربط

توجد بنية جاهزة لمسارات تسجيل الدخول، إنشاء الحساب، تسجيل الدخول عبر Google/Facebook، تسجيل الخروج، المستخدم الحالي، استعادة كلمة المرور، إعادة تعيينها، والتحقق من البريد. كما توجد واجهات RemoteDataSource وRepositories للمحادثات والرسائل والنماذج والملفات والإشعارات وAgents والاشتراكات والمدفوعات.

## نقاط Backend Integration

تم توضيح نقاط المصادقة داخل `AuthController` بتعليقات TODO. كما توجد نقطة تسجيل RemoteDataSource في `core/di/injection.dart`. وتوجد عقود المستودعات ومصادر البيانات في `lib/data/repositories` و`lib/data/datasources/remote` لتوصيل API الفعلي مستقبلًا دون إنشاء طبقة موازية.

## ما تمت إزالته

تمت إزالة وضع Demo المحلي، وبيانات المستخدم التجريبية، وتوكنات Demo، والمحادثات التجريبية، والنماذج المحلية التجريبية، وخطة الاشتراك التجريبية، ومسار Try demo. لم تتم إضافة Mock Response أو Fake API أو محاكاة Offline جديدة.

## ما بقي بانتظار Backend

تحتاج كل البيانات الديناميكية، مثل بيانات المستخدم والمحادثات والرسائل والخطط والأسعار والعملات وحالات الدفع والإشعارات والملفات، إلى استجابة Backend فعلية. عند غياب البيانات يجب أن تعرض الواجهات Loading أو Empty أو Unavailable State، ولا يتم افتراض حالة Premium أو نجاح الدفع أو خطة معينة.

## التحقق

تم إجراء بحث نصي عن مراجع Mock/Demo والبيانات التجريبية النشطة ولم تظهر مسارات تشغيلية لها. تعذر تشغيل `dart format` و`flutter analyze` و`flutter run` لأن Dart وFlutter SDK غير مثبتين في بيئة التنفيذ الحالية. لذلك لا يُعد البناء النهائي ناجحًا قبل تشغيل هذه الأوامر في بيئة Flutter.
