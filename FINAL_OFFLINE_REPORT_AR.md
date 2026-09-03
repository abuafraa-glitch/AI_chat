# تقرير تعديل نسخة main — Offline / Demo Mode

تم تنزيل فرع `main` من المستودع `https://github.com/abuafraa-glitch/AI-chat.git` عند الالتزام `6ac3188`، باستخدام sparse checkout لاستبعاد مجلدات المنصات: `android` و`ios` و`web` و`linux` و`macos` و`windows`.

## التعديلات

| الملف | التعديل |
|---|---|
| `lib/core/config/offline_mode.dart` | إعداد مركزي `OFFLINE_MODE` وقيمته الافتراضية `true`. |
| `lib/core/di/injection.dart` | اختيار `MockRemoteDataSource` في Demo مع إبقاء `RemoteDataSourceImpl` للإنتاج. |
| `lib/data/datasources/remote/mock_remote_data_source.dart` | Mock محلي يغطي عقد RemoteDataSource كاملًا: المصادقة، النماذج، المحادثات، الرسائل، الملفات، الإشعارات، الوكلاء، المدفوعات، الاشتراكات والبحث. |
| `lib/presentation/blocs/auth_controller.dart` | جلسة Demo محلية تلقائية، وتجاوز OAuth في Offline فقط. |
| `lib/presentation/screens/login_screen.dart` | شارة Offline/Demo وزر دخول تجريبي. |
| `OFFLINE_DEMO.md` | تعليمات التشغيل والتبديل. |

لم يتم حذف أو تعطيل نهائيًا أي كود Backend أو Repositories أو Services أو Authentication. لا توجد مجلدات منصات في الأرشيف النهائي، ويمكن توليد Web عند الحاجة بواسطة `flutter create . --platforms web`.

## التفعيل

```bash
flutter run -d web-server --dart-define=OFFLINE_MODE=true
```

وللعودة إلى Backend الحقيقي:

```bash
flutter run -d web-server --dart-define=OFFLINE_MODE=false
```

## التحقق

الفحص الثابت نجح، وطبقة Mock لا تستورد أو تستدعي Dio أو HTTP أو WebSocket، كما بقيت ملفات الشبكة الإنتاجية موجودة. كذلك نجح `git diff --check` ولم تظهر أخطاء whitespace.

تعذر تشغيل `flutter pub get` و`flutter analyze` و`flutter test` في بيئة مانوس الحالية لأن Flutter SDK غير مثبت، وكانت النتيجة `flutter: command not found` لكل أمر. يجب تنفيذ هذه الأوامر في Termux بعد تثبيت Flutter.

بعد فك الضغط في Termux، نفّذ:

```bash
flutter create . --platforms web
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=OFFLINE_MODE=true
```
