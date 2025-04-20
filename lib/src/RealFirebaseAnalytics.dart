import 'package:firebase_analytics/firebase_analytics.dart';

import 'IFirebaseAnalytics.dart';

class RealFirebaseAnalytics implements IFirebaseAnalytics
{
    @override
    Future<void> logEvent({required String name, Map<String, Object>? parameters})
    => FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

    @override
    Future<void> setAnalyticsCollectionEnabled(bool startEnabled)
    => FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(startEnabled);

    @override
    Future<void> setCurrentScreen({required String screenName, required String screenClass})
    => FirebaseAnalytics.instance.logScreenView(screenName: screenName, screenClass: screenClass);

    @override
    Future<void> setUserId({required String id})
    => FirebaseAnalytics.instance.setUserId(id: id);

    @override
    Future<void> setUserProperty({required String name, required String value})
    => FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
}
