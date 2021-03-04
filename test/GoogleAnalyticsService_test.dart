import 'package:eggnstone_google_analytics/eggnstone_google_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

const String TEXT_40 = 'Test_40_chars_45678901234567890123456789';
const String TEXT_41 = 'Test_41_chars_456789012345678901234567890';
const String TEXT_100 = 'Test_100_chars_5678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
const String TEXT_101 = 'Test_101_chars_56789012345678901234567890123456789012345678901234567890123456789012345678901234567891';

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
    group('track with name only', ()
    {
        test('Only with name, empty name', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('');
            assert(false, 'fix mockito'); // verifyNever(logInfo(any));
            assert(false, 'fix mockito'); // verifyNever(logDebug(any));
            assert(false, 'fix mockito'); // verifyNever(logWarning(any));
            assert(false, 'fix mockito'); // verifyNever(logError(any));
        });

        test('Only with name, length ok', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('Test');
            assert(false, 'fix mockito'); // verify(logInfo(argThat(equals('GoogleAnalytics: Test'))));
            assert(false, 'fix mockito'); // verifyNever(logDebug(any));
            assert(false, 'fix mockito'); // verifyNever(logWarning(any));
            assert(false, 'fix mockito'); // verifyNever(logError(any));
        });

        test('Only with name, length barely ok', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_40);
            assert(false, 'fix mockito'); // verify(logInfo(argThat(equals('GoogleAnalytics: ' + TEXT_40))));
            assert(false, 'fix mockito'); // verifyNever(logDebug(any));
            assert(false, 'fix mockito'); // verifyNever(logWarning(any));
            assert(false, 'fix mockito'); // verifyNever(logError(any));
        });

        test('Only with name, length too long', ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_41);

            // Behavior changed so that name just gets shortened

            /*
            verifyInOrder([
                logError('##################################################'),
                logError('# Error: Event name "Test_41_chars_456789012345678901234567890" is too long! Is=41 Max=40'),
            ]);
            verifyNever(logInfo(any));
            */

            assert(false, 'fix mockito'); // verify(logInfo(argThat(equals('GoogleAnalytics: ' + TEXT_41.substring(0, 40)))));

            assert(false, 'fix mockito'); // verifyNever(logDebug(any));
            assert(false, 'fix mockito'); // verifyNever(logWarning(any));
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
