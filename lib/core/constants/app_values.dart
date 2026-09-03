/// Default values used across the Hajeen AI platform.
///
/// These are **fallbacks** the UI and domain layers use when the
/// canonical source (user profile, server, cache) is unavailable.
/// They are intentionally generic and never environment-specific.
abstract final class AppValues {
  const AppValues._();

  // ---- Empty / placeholder content -----------------------------------------

  /// Text shown when a chat list has no conversations.
  static const String emptyConversationsTitle = 'No conversations yet';

  /// Text shown when a model picker has no models.
  static const String emptyModelsTitle = 'No models available';

  /// Text shown when a search returns no results.
  static const String emptySearchTitle = 'No results found';

  /// Text shown when a notification feed is empty.
  static const String emptyNotificationsTitle = 'You are all caught up';

  /// Text shown when a file list is empty.
  static const String emptyFilesTitle = 'No files uploaded';

  // ---- Numeric / count fallbacks -------------------------------------------

  /// Default value used when a count cannot be resolved.
  static const int defaultCount = 0;

  /// Default numeric seed used for skeleton-loader animation phases.
  static const int skeletonSeed = 7;

  /// Default opacity applied to disabled controls.
  static const double disabledOpacity = 0.5;

  /// Default opacity applied to pressed controls.
  static const double pressedOpacity = 0.7;

  /// Default value for an unset timestamp (milliseconds since epoch).
  static const int unsetTimestamp = 0;

  // ---- HTTP / network fallbacks --------------------------------------------

  /// Default `User-Agent` template populated by the interceptor.
  static const String defaultUserAgent = 'HajeenAI/1.0.0 (Flutter)';

  /// Default `X-Client-Name` value.
  static const String defaultClientName = 'hajeen_ai_flutter';

  /// Default `X-Platform` value when none is reported by the device.
  static const String defaultPlatform = 'unknown';

  // ---- Pagination fallbacks ------------------------------------------------

  /// Fallback page number when no pagination metadata is available.
  static const int defaultPage = 1;

  /// Fallback page size when no size is requested.
  static const int defaultPageSize = 20;

  /// Fallback total count when the server omits it.
  static const int defaultTotalCount = 0;

  // ---- Validation fallbacks ------------------------------------------------

  /// Default message shown when validation fails without specifics.
  static const String genericValidationError = 'Invalid value';

  /// Default message shown when a network call fails without specifics.
  static const String genericNetworkError = 'Network error. Please try again.';

  /// Default message shown when the server fails without specifics.
  static const String genericServerError = 'Server error. Please try again.';

  /// Default message shown on an unknown error.
  static const String genericUnknownError = 'Something went wrong.';

  // ---- UI defaults ----------------------------------------------------------

  /// Default scale applied to text when no user preference is set.
  static const double defaultTextScale = 1.0;

  /// Default minimum scale a user can pick.
  static const double minTextScale = 0.8;

  /// Default maximum scale a user can pick.
  static const double maxTextScale = 1.5;

  /// Default step used by the text-scale slider.
  static const double textScaleStep = 0.1;

  // ---- Locale fallbacks -----------------------------------------------------

  /// Default locale code used when the device locale is unsupported.
  static const String defaultLocaleCode = 'en';

  /// Default country code paired with [defaultLocaleCode].
  static const String defaultCountryCode = 'US';

  /// Default temperature forwarded to generation requests.
  static const double defaultTemperature = 0.7;

  /// Default `max_tokens` cap for completion requests.
  static const int defaultMaxTokens = 1024;

  /// Default `top_p` nucleus sampling value.
  static const double defaultTopP = 1.0;

  /// Default `frequency_penalty` value.
  static const double defaultFrequencyPenalty = 0.0;

  /// Default `presence_penalty` value.
  static const double defaultPresencePenalty = 0.0;
}
