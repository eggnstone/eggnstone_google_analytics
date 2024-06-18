abstract interface class IFirebaseAnalytics
{
    // ignore: avoid_positional_boolean_parameters
    Future<void> setAnalyticsCollectionEnabled(bool startEnabled);

    Future<void> setCurrentScreen({required String screenName, required String screenClass});

    Future<void> logEvent({required String name, Map<String, Object>? parameters});

    Future<void> setUserId({required String id});

    Future<void> setUserProperty({required String name, required String value});
}
