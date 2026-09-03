import 'package:ai_chat/core/config/app_config.dart';
import 'package:ai_chat/core/config/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

AppConfig configWithBase(String base) {
  return AppConfig.internal(
    appName: 'Hajeen AI',
    appVersion: 'test',
    apiBaseUrl: base,
    webSocketUrl: 'wss://ws.example.com',
    apiVersion: 'v1',
    flavor: Flavor.production,
    connectionTimeout: const Duration(seconds: 1),
    receiveTimeout: const Duration(seconds: 1),
    sendTimeout: const Duration(seconds: 1),
    debugMode: false,
    enableLogging: false,
    featureFlags: const FeatureFlags(),
  );
}

void main() {
  test('uses a non-routable placeholder for an empty base', () {
    expect(
      configWithBase('').resolvedApiUrl,
      'http://backend-not-configured.invalid/api/v1',
    );
  });

  test('uses a non-routable placeholder for a relative base', () {
    expect(
      configWithBase('/api').resolvedApiUrl,
      'http://backend-not-configured.invalid/api/v1',
    );
  });

  test('preserves a valid HTTPS base and normalizes its API path', () {
    expect(
      configWithBase('https://backend.example.com/').resolvedApiUrl,
      'https://backend.example.com/api/v1',
    );
  });
}
