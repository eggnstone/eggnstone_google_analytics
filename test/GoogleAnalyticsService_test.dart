import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_analytics/eggnstone_google_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

const String TEXT_40 = 'Test_40_chars_45678901234567890123456789';
const String TEXT_41 = 'Test_41_chars_456789012345678901234567890';
const String TEXT_100 = 'Test_100_chars_5678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
const String TEXT_101 = 'Test_101_chars_56789012345678901234567890123456789012345678901234567890123456789012345678901234567891';

class MockLoggerService extends Mock
    implements LoggerService
{}

class MockFirebaseAnalytics extends Mock
    implements FirebaseAnalytics
{}

void main()
{
    TestWidgetsFlutterBinding.ensureInitialized();
    testLog();
}

void testLog()
{
    LoggerService logger = MockLoggerService();
    GetIt.instance.registerSingleton<LoggerService>(logger);
    //GetIt.instance.registerSingleton<LoggerService>(LoggerService(true));

    group('track with name only', ()
    {
        test('Only with name, empty name', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('');
            verifyNever(logger.logInfo(any));
            verifyNever(logger.logDebug(any));
            verifyNever(logger.logWarning(any));
            verifyNever(logger.logError(any));
        });

        test('Only with name, length ok', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('Test');
            verify(logger.logInfo(argThat(equals('Analytics: Test'))));
            verifyNever(logger.logDebug(any));
            verifyNever(logger.logWarning(any));
            verifyNever(logger.logError(any));
        });

        test('Only with name, length barely ok', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_40);
            verify(logger.logInfo(argThat(equals('Analytics: ' + TEXT_40))));
            verifyNever(logger.logDebug(any));
            verifyNever(logger.logWarning(any));
            verifyNever(logger.logError(any));
        });

        test('Only with name, length too long', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_41);

            verifyInOrder([
                logger.logError('##################################################'),
                logger.logError('# Error: Event name "Test_41_chars_456789012345678901234567890" is too long! Is=41 Max=40'),
            ]);

            verifyNever(logger.logInfo(any));
            verifyNever(logger.logDebug(any));
            verifyNever(logger.logWarning(any));
        });
    });
}

/*
    log(text40);
    log(text41); // name too long

    logAction(text40, action: text100);
    logAction(text40, action: text101); // action too long

    logValue(text40, value: text100);
    logValue(text40, value: text101); // value too long

    logActionAndValue

    log(text40, {text40: text100}); // all ok
    log(text41, {text40: text100}); // name too long
    log(text40, {text41: text100}); // key too long
    log(text40, {text40: text101}); // value too long
    log(text41, {text41: text101}); // all too long
*/
