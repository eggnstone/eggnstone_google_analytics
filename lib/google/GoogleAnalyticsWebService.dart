import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_analytics/google/IGoogleAnalyticsService.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';

/// Requires [LoggerService]
class GoogleAnalyticsService
    with LoggerMixin
    implements IGoogleAnalyticsService
{
    static const String EVENT_NAME__TUTORIAL_BEGIN = 'tutorial_begin';
    static const String EVENT_NAME__TUTORIAL_COMPLETE = 'tutorial_complete';
    static const int MAX_EVENT_NAME_LENGTH = 40;
    static const int MAX_PARAM_NAME_LENGTH = 40;
    static const int MAX_PARAM_VALUE_LENGTH = 100;

    final FirebaseAnalyticsWeb _firebaseAnalytics;

    bool _isEnabled;
    String _currentScreen = '';

    GoogleAnalyticsService._internal(this._firebaseAnalytics, this._isEnabled);

    /// Requires [LoggerService]
    /// @param startEnabled The state the service should start with.
    static Future<IGoogleAnalyticsService> create(bool startEnabled)
    => GoogleAnalyticsService.createMockable(FirebaseAnalyticsWeb(), startEnabled);

    /// Requires [LoggerService]
    /// For testing purposes only.
    static Future<IGoogleAnalyticsService> createMockable(FirebaseAnalyticsWeb firebaseAnalytics, bool startEnabled)
    async
    {
        var instance = GoogleAnalyticsService._internal(firebaseAnalytics, startEnabled);
        instance._firebaseAnalytics.setAnalyticsCollectionEnabled(startEnabled);
        return instance;
    }

    /// The state of the service (if it reports to Google Analytics or not).
    @override
    bool get isEnabled
    => _isEnabled;

    /// The state of the service (if it reports to Google Analytics or not).
    @override
    set isEnabled(bool newValue)
    {
        _isEnabled = newValue;
        _firebaseAnalytics.setAnalyticsCollectionEnabled(newValue);
    }

    /// The current screen.
    @override
    String get currentScreen
    => _currentScreen;

    /// The current screen.
    @override
    set currentScreen(String newValue)
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setCurrentScreen: ' + newValue);

        _currentScreen = newValue;

        if (_isEnabled)
            _firebaseAnalytics.setCurrentScreen(screenName: newValue, screenClassOverride: newValue);
    }

    /// Track an event.
    /// @param name The name of the event.
    /// @param params The optional parameters.
    @override
    void track(String name, [Map<String, dynamic>? params])
    async
    {
        if (name.isEmpty)
            return;

        // Check limits (https://support.google.com/firebase/answer/9237506?hl=en)

        if (name.length > GoogleAnalyticsService.MAX_EVENT_NAME_LENGTH)
            name = name.substring(0, GoogleAnalyticsService.MAX_EVENT_NAME_LENGTH);

        Map<String, dynamic>? safeParams;
        if (params != null)
        {
            safeParams = {};

            for (String key in params.keys)
            {
                Object? value = params[key];
                if (value == null)
                    continue;

                if (key.length > GoogleAnalyticsService.MAX_PARAM_NAME_LENGTH)
                    key = key.substring(0, GoogleAnalyticsService.MAX_PARAM_NAME_LENGTH);

                if (value is String)
                {
                    String valueString = value;
                    if (valueString.length > GoogleAnalyticsService.MAX_PARAM_VALUE_LENGTH)
                        valueString = valueString.substring(0, GoogleAnalyticsService.MAX_PARAM_VALUE_LENGTH);

                    safeParams[key] = valueString;
                }
                else
                    safeParams[key] = value;
            }
        }

        String s = (_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': ' + name;

        if (safeParams != null)
            for (String key in safeParams.keys)
                s += ' $key=${safeParams[key]}';

        logger.logInfo(s);

        if (_isEnabled)
            _firebaseAnalytics.logEvent(name: name, parameters: safeParams);
    }

    /// Track an action event.
    /// @param name The name of the event.
    /// @param action The name of the action.
    @override
    void trackAction(String name, String action)
    => track(name, {'Action': action});

    /// Track a value event.
    /// @param name The name of the event.
    /// @param value The name of the value.
    @override
    void trackValue(String name, Object value)
    => track(name, {'Value': value});

    /// Track an action-and-value event.
    /// @param name The name of the event.
    /// @param action The name of the action.
    /// @param value The name of the value.
    @override
    void trackActionAndValue(String name, String action, Object value)
    => track(name, {'Action': action, 'Value': value});

    /// Track a warning.
    /// @param message The warning message.
    /// @param params The optional parameters.
    @override
    void trackWarning(String message, [Map<String, dynamic>? params])
    async
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackWarning: $message / $params');

        if (params == null)
            params = {};

        params['Message'] = message;

        if (_isEnabled)
            track('Warning', params);
    }

    /// Track an error.
    /// @param message The error message.
    /// @param params The optional parameters.
    @override
    void trackError(String message, [Map<String, dynamic>? params])
    async
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackError: $message / $params');

        if (params == null)
            params = {};

        params['Message'] = message;

        if (_isEnabled)
            track('Error', params);
    }

    /// Track a warning with an exception.
    /// @param source The source of the warning.
    /// @param stackTrace The stack trace.
    @override
    void trackWarningWithException(String source, dynamic e, [dynamic stackTrace])
    async
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackWarningWithException: $source / $e / $stackTrace');

        if (_isEnabled)
        {
            Map<String, dynamic>? params = {'Message': e.toString()};
            if (stackTrace != null)
                params[ 'StackTrace'] = stackTrace.toString();

            track('Warning', params);
        }
    }

    /// Track an error with an exception.
    /// @param source The source of the error.
    /// @param stackTrace The stack trace.
    @override
    void trackErrorWithException(String source, dynamic e, [dynamic stackTrace])
    async
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackErrorWithException: $source / $e / $stackTrace');

        if (_isEnabled)
        {
            Map<String, dynamic>? params = {'Message': e.toString()};
            if (stackTrace != null)
                params[ 'StackTrace'] = stackTrace.toString();

            track('Error', params);
        }
    }

    @override
    void setUserId(String value)
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserId: $value');

        if (_isEnabled)
            _firebaseAnalytics.setUserId(value);
    }

    @override
    void setUserProperty(String name, String value, {bool force = false})
    {
        logger.logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserProperty: name=$name value=$value force=$force');

        if (_isEnabled || force)
            _firebaseAnalytics.setUserProperty(name: name, value: value);
    }
}
