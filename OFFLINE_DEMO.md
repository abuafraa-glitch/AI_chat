# Offline / Demo Mode

The app defaults to `OFFLINE_MODE=true` through `lib/core/config/offline_mode.dart`.
In this mode GetIt injects `MockRemoteDataSource` behind the existing
`RemoteDataSource` contract. The mock has no Dio, HTTP, WebSocket, or backend
imports and supplies local auth, models, conversations, messages, files,
notifications, agents, payments, subscriptions, and search data.

The original `RemoteDataSourceImpl`, Dio network stack, repositories, services,
and authentication integration remain in the project. To return to production:

```bash
flutter run -d web-server --dart-define=OFFLINE_MODE=false
```

This checkout intentionally excludes all platform folders (`android`, `ios`,
`web`, `linux`, `macos`, `windows`). After extracting it on Termux, generate
only the Web bootstrap files with:

```bash
flutter create . --platforms web
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=OFFLINE_MODE=true
```
