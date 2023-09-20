import 'package:firebase_analytics/firebase_analytics.dart';

import 'IFirebaseAnalytics.dart';

class RealFirebaseAnalytics implements IFirebaseAnalytics
{
    @override
    Future<void> logEvent({required String name, Map<String, dynamic>? parameters})
    async => FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

    @override
    Future<void> setAnalyticsCollectionEnabled(bool startEnabled)
    async => FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(startEnabled);

    @override
    Future<void> setCurrentScreen({required String screenName, required String screenClassOverride})
    async => FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName, screenClassOverride: screenClassOverride);

    @override
    Future<void> setUserId({required String id})
    async => FirebaseAnalytics.instance.setUserId(id: id);

    @override
    Future<void> setUserProperty({required String name, required String value})
    async => FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
}
