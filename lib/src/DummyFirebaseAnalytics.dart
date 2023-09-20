import 'package:eggnstone_dart/eggnstone_dart.dart';

import 'IFirebaseAnalytics.dart';

class DummyFirebaseAnalytics implements IFirebaseAnalytics
{
    @override
    Future<void> logEvent({required String name, Map<String, dynamic>? parameters})
    async => logDebug('DummyFirebaseAnalytics.logEvent: $name / $parameters');

    @override
    Future<void> setAnalyticsCollectionEnabled(bool startEnabled)
    async => logDebug('DummyFirebaseAnalytics.setAnalyticsCollectionEnabled: $startEnabled');

    @override
    Future<void> setCurrentScreen({required String screenName, required String screenClassOverride})
    async => logDebug('DummyFirebaseAnalytics.setCurrentScreen: $screenName / $screenClassOverride');

    @override
    Future<void> setUserId({required String id})
    async => logDebug('DummyFirebaseAnalytics.setUserId: $id');

    @override
    Future<void> setUserProperty({required String name, required String value})
    async => logDebug('DummyFirebaseAnalytics.setUserProperty: $name / $value');
}
