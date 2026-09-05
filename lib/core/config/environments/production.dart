import '../app_config.dart';
import '../flavor.dart';

/// Configuration for the customer-facing production environment.
///
/// All debug surfaces and verbose logging are disabled, network
/// timeouts are tight, and feature flags expose only what has been
/// fully released. The defaults baked into [FeatureFlags] are
/// production-safe; anything added here is an explicit opt-in.
base class ProductionConfig extends EnvironmentConfig {
  const ProductionConfig();

  @override
  AppConfig build() {
    return const AppConfig.internal(
      appName: const String.fromEnvironment(
        'APP_NAME',
        defaultValue: 'Hajeen AI',
      ),
      appVersion: const String.fromEnvironment(
        'APP_VERSION',
        defaultValue: '1.0.0+1',
      ),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        // TODO: provide the backend URL through deployment configuration.
        defaultValue: '',
      ),
      aiBaseUrl: const String.fromEnvironment(
        'AI_BASE_URL',
        defaultValue: 'https://cbbm90nleo4jji-8000.proxy.runpod.net/v1',
      ),
      aiModel: const String.fromEnvironment(
        'AI_MODEL',
        defaultValue: 'Qwen/Qwen2.5-7B-Instruct',
      ),
      aiApiKey: const String.fromEnvironment('AI_API_KEY'),
      aiSystemPrompt: const String.fromEnvironment(
        'AI_SYSTEM_PROMPT',
        defaultValue: 'أنت مساعد ذكاء اصطناعي يدعى هجين.',
      ),
      aiMaxTokens: const int.fromEnvironment('AI_MAX_TOKENS', defaultValue: 150),
      webSocketUrl: const String.fromEnvironment(
        'WS_BASE_URL',
        defaultValue: '',
      ),
      apiVersion: const String.fromEnvironment(
        'API_VERSION',
        defaultValue: 'v1',
      ),
      flavor: Flavor.production,
      connectionTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      debugMode: false,
      enableLogging: false,
      featureFlags: const FeatureFlags(
        // Core, verified surfaces that do not depend on unverified
        // backend contracts.
        enableChat: true,
        enableAiModelSelection: true,
        enableWebSocketStreaming: true,
        enableMultiModelSwitching: true,
        // These implemented app sections must remain reachable in production.
        // Disabling them here makes the route guard silently redirect taps to
        // the chat tab, which is indistinguishable from a broken link.
        enableSubscriptions: true,
        enablePayments: true,
        enableFileManagement: true,
        enableSearch: false,
        enableRag: false,
        enableAgents: true,
        enableNotifications: true,
      ),
    );
  }
}
