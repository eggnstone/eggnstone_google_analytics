import 'dart:async';

import 'package:eggnstone_dart/eggnstone_dart.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'IGoogleAnalyticsService.dart';

class GoogleAnalyticsService extends IGoogleAnalyticsService
{
    static const String EVENT_NAME__TUTORIAL_BEGIN = 'tutorial_begin';
    static const String EVENT_NAME__TUTORIAL_COMPLETE = 'tutorial_complete';
    static const int MAX_EVENT_NAME_LENGTH = 40;
    static const int MAX_PARAM_NAME_LENGTH = 40;
    static const int MAX_PARAM_VALUE_LENGTH = 100;

    final FirebaseAnalytics _firebaseAnalytics;

    bool _isEnabled;
    bool _isDebugEnabled;
    String _currentScreen = '';

    GoogleAnalyticsService._internal(this._firebaseAnalytics, this._isEnabled, this._isDebugEnabled);

    /// @param startEnabled The state the service should start with.
    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleAnalyticsService> create(bool startEnabled, bool startDebugEnabled)
    => GoogleAnalyticsService.createMockable(FirebaseAnalytics.instance, startEnabled, startDebugEnabled);

    /// For testing purposes only.
    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleAnalyticsService> createMockable(FirebaseAnalytics firebaseAnalytics, bool startEnabled, bool startDebugEnabled)
    async
    {
        final GoogleAnalyticsService instance = GoogleAnalyticsService._internal(firebaseAnalytics, startEnabled, startDebugEnabled);
        await instance._firebaseAnalytics.setAnalyticsCollectionEnabled(startEnabled);
        return instance;
    }

    @override
    bool get isEnabled
    => _isEnabled;

    @override
    set isEnabled(bool newValue)
    {
        _isEnabled = newValue;
        unawaited(_firebaseAnalytics.setAnalyticsCollectionEnabled(newValue));
    }

    @override
    bool get isDebugEnabled
    => _isDebugEnabled;

    @override
    set isDebugEnabled(bool newValue)
    {
        _isDebugEnabled = newValue;
    }

    @override
    String get currentScreen
    => _currentScreen;

    @override
    set currentScreen(String newValue)
    {
        if (newValue == '_placeHolder_')
            return;

        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setCurrentScreen: ' + newValue);

        _currentScreen = newValue;

        if (_isEnabled)
            unawaited(_firebaseAnalytics.setCurrentScreen(screenName: newValue, screenClassOverride: newValue));
    }

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
            await _firebaseAnalytics.logEvent(name: safeName, parameters: safeParams);
    }

    @override
    void trackAction(String name, String action)
    => unawaited(track(name, <String, dynamic>{'Action': action}));

    @override
    void trackValue(String name, Object value)
    => unawaited(track(name, <String, dynamic>{'Value': value}));

    @override
    void trackNumberValue(String name, Object numberValue)
    => unawaited(track(name, <String, dynamic>{'NumberValue': numberValue}));

    @override
    void trackTextValue(String name, Object textValue)
    => unawaited(track(name, <String, dynamic>{'TextValue': textValue}));

    @override
    void trackActionAndValue(String name, String action, Object value)
    => unawaited(track(name, <String, dynamic>{'Action': action, 'Value': value}));

    @override
    void trackActionAndNumberValue(String name, String action, Object numberValue)
    => unawaited(track(name, <String, dynamic>{'Action': action, 'NumberValue': numberValue}));

    @override
    void trackActionAndTextValue(String name, String action, Object textValue)
    => unawaited(track(name, <String, dynamic>{'Action': action, 'TextValue': textValue}));

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
    // ignore: avoid_renaming_method_parameters
    void setUserId(String id)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserId: $id');

        if (_isEnabled)
            unawaited(_firebaseAnalytics.setUserId(id: id));
    }

    @override
    void setUserProperty(String key, String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleAnalytics' : 'Disabled-GoogleAnalytics') + ': setUserProperty: key=$key value=$value');

        if (_isEnabled)
            unawaited(_firebaseAnalytics.setUserProperty(name: key, value: value));
    }
}
