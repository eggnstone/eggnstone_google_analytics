import 'package:eggnstone_flutter/eggnstone_flutter.dart';

abstract class IGoogleAnalyticsService extends IAnalyticsService
{
    // TODO: shorten strings instead of expecting shortened strings

    /// User properties are attributes you define to describe segments of your user base, such as language preference or geographic location.
    /// These can be used to define audiences for your app.
    /// See https://firebase.google.com/docs/analytics/user-properties?platform=android
    void setUserProperty(String name, String value, {bool force = false});

    /// Google Analytics has a setUserID call, which allows you to store a user ID for the individual using your app.
    /// This call is optional, and is generally used by organizations that want to use Analytics in conjunction with BigQuery to associate analytics data for the same user across multiple apps, multiple devices, or multiple analytics providers.
    /// See https://firebase.google.com/docs/analytics/userid
    void setUserId(String value);

    String getOrCreateStackTrace(StackTrace? stackTrace, [int levelsToRemove = 2])
    {
        if (stackTrace != null)
            return stackTrace.toString();

        String s = StackTrace.current.toString();
        int pos = s.indexOf('#$levelsToRemove      ');
        if (pos == -1)
            return s;

        return s.substring(pos);
    }
}
