import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';

import 'IGoogleAnalyticsService.dart';

class GoogleAnalyticsService extends IGoogleAnalyticsService
{
    static const String EVENT_NAME__TUTORIAL_BEGIN = 'tutorial_begin';
    static const String EVENT_NAME__TUTORIAL_COMPLETE = 'tutorial_complete';
    static const int MAX_EVENT_NAME_LENGTH = 40;
    static const int MAX_PARAM_NAME_LENGTH = 40;
    static const int MAX_PARAM_VALUE_LENGTH = 100;

    final FirebaseAnalyticsWeb _firebaseAnalytics;

    bool _isEnabled;
    String _currentScreen = '';

    @override
    bool isDebugEnabled = false;

    GoogleAnalyticsService._internal(this._firebaseAnalytics, this._isEnabled);

    /// @param startEnabled The state the service should start with.
    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleAnalyticsService> create(bool startEnabled)
    => GoogleAnalyticsService.createMockable(FirebaseAnalyticsWeb(), startEnabled);

    /// For testing purposes only.
    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleAnalyticsService> createMockable(FirebaseAnalyticsWeb firebaseAnalytics, bool startEnabled)
    async
    {
        final GoogleAnalyticsService instance = GoogleAnalyticsService._internal(firebaseAnalytics, startEnabled);
        await instance._firebaseAnalytics.setAnalyticsCollectionEnabled(startEnabled);
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
        if (newValue == '_placeHolder_')
            return;

        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setCurrentScreen: ' + newValue);

        _currentScreen = newValue;

        if (_isEnabled)
            _firebaseAnalytics.setCurrentScreen(screenName: newValue, screenClassOverride: newValue);
    }

    /// Track an event.
    /// @param name The name of the event.
    /// @param params The optional parameters.
    @override
    Future<void> track(String name, [Map<String, dynamic>? params])
    async
    {
        if (name.isEmpty)
            return;

        // Check limits (https://support.google.com/firebase/answer/9237506?hl=en)

        String safeName = name;
        if (safeName.length > GoogleAnalyticsService.MAX_EVENT_NAME_LENGTH)
            safeName = safeName.substring(0, GoogleAnalyticsService.MAX_EVENT_NAME_LENGTH);

        Map<String, dynamic>? safeParams;
        if (params != null)
        {
            safeParams = <String, dynamic>{};

            for (String key in params.keys)
            {
                final Object? value = params[key];
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

        // ignore: prefer_interpolation_to_compose_strings
        String s = (_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': ' + safeName;

        if (safeParams != null)
            for (final String key in safeParams.keys)
            {
                // ignore: use_string_buffers
                s += ' $key=${safeParams[key]}';
            }

        logInfo(s);

        if (_isEnabled)
        {
            try
            {
                if (isDebugEnabled)
                    logInfo('GoogleAnalyticsService.track: calling _firebaseAnalytics.logEvent ...');
                await _firebaseAnalytics.logEvent(name: safeName, parameters: safeParams);
                if (isDebugEnabled)
                    logInfo('GoogleAnalyticsService.track: called _firebaseAnalytics.logEvent.');
            }
            on Exception catch (e)
            {
                logError('GoogleAnalyticsService.track/_firebaseAnalytics.logEvent', e);
            }
        }
        else
        {
            if (isDebugEnabled)
                logInfo('GoogleAnalyticsService.track: not calling _firebaseAnalytics.logEvent because not enabled.');
        }
    }

    /// Track an action event.
    /// @param name The name of the event.
    /// @param action The name of the action.
    @override
    void trackAction(String name, String action)
    => track(name, <String, dynamic>{'Action': action});

    /// Track a value event.
    /// @param name The name of the event.
    /// @param value The name of the value.
    @override
    void trackValue(String name, Object value)
    => track(name, <String, dynamic>{'Value': value});

    /// Track an action-and-value event.
    /// @param name The name of the event.
    /// @param action The name of the action.
    /// @param value The name of the value.
    @override
    void trackActionAndValue(String name, String action, Object value)
    => track(name, <String, dynamic>{'Action': action, 'Value': value});

    /// Track a warning.
    /// @param message The warning message.
    /// @param params The optional parameters.
    @override
    Future<void> trackWarning(String message, [Map<String, dynamic>? params])
    async
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackWarning: $message / $params');

        params ??= <String, dynamic>{};
        params['Message'] = message;

        if (_isEnabled)
            await track('Warning', params);
    }

    /// Track an error.
    /// @param message The error message.
    /// @param params The optional parameters.
    @override
    Future<void> trackError(String message, [Map<String, dynamic>? params])
    async
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackError: $message / $params');

        params ??= <String, dynamic>{};
        params['Message'] = message;

        if (_isEnabled)
            await track('Error', params);
    }

    /// Track a warning with an exception.
    /// @param source The source of the warning.
    /// @param stackTrace The stack trace.
    @override
    Future<void> trackWarningWithException(String source, dynamic e, [StackTrace? stackTrace])
    async
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackWarningWithException: $source / $e / $stackTrace');

        if (_isEnabled)
        {
            final Map<String, dynamic> params =
            <String, dynamic>{
                'Message': e.toString(),
                'StackTrace': getOrCreateStackTrace(stackTrace)
            };

            await track('Warning', params);
        }
    }

    /// Track an error with an exception.
    /// @param source The source of the error.
    /// @param stackTrace The stack trace.
    @override
    Future<void> trackErrorWithException(String source, dynamic e, [StackTrace? stackTrace])
    async
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': trackErrorWithException: $source / $e / $stackTrace');

        if (_isEnabled)
        {
            final Map<String, dynamic> params =
            <String, dynamic>{
                'Message': e.toString(),
                'StackTrace': getOrCreateStackTrace(stackTrace)
            };

            await track('Error', params);
        }
    }

    @override
    void setUserId(String id)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserId: $id');

        if (_isEnabled)
            _firebaseAnalytics.setUserId(id: id);
    }

    @override
    void setUserProperty(String key, String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserProperty: key=$key value=$value');

        if (_isEnabled)
            _firebaseAnalytics.setUserProperty(name: key, value: value);
    }
}
