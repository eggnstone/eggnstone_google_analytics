import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_analytics/eggnstone_google_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'GoogleAnalyticsService_test.mocks.dart';

const String TEXT_40 = 'Test_40_chars_45678901234567890123456789';
const String TEXT_41 = 'Test_41_chars_456789012345678901234567890';
const String TEXT_100 = 'Test_100_chars_5678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
const String TEXT_101 = 'Test_101_chars_56789012345678901234567890123456789012345678901234567890123456789012345678901234567891';

const String TIME_REGEX = r'\d{2}:\d{2}:\d{2}';

@GenerateMocks(<Type>[FirebaseAnalytics])
void main()
{
    TestWidgetsFlutterBinding.ensureInitialized();
    isLoggerEnabled = true;
    useNewLogger = false;
    testLog();
}

void testLog()
{
    group('track with name only', ()
    {
        List<String> logOnlyWithNameEmptyName = [];
        test('Only with name, empty name', overridePrint(logOnlyWithNameEmptyName, ()
        async
        {
            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('');

            expect(logOnlyWithNameEmptyName.length, 0);
        }));

        List<String> logOnlyWithNameLengthOk = [];
        test('Only with name, length ok', overridePrint(logOnlyWithNameLengthOk, ()
        async
        {
            const String MESSAGE = 'GoogleAnalytics: Test';
            const String ANNOTATED_MESSAGE = 'Info:  ' + MESSAGE;

            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track('Test');

            expect(logOnlyWithNameLengthOk.length, 1);
            expect(RegExp('^' + TIME_REGEX + ' ' + ANNOTATED_MESSAGE + '\$').hasMatch(logOnlyWithNameLengthOk[0]), isTrue);
        }));

        List<String> logOnlyWithNameLengthBarelyOk = [];
        test('Only with name, length barely ok', overridePrint(logOnlyWithNameLengthBarelyOk, ()
        async
        {
            const String MESSAGE = 'GoogleAnalytics: ' + TEXT_40;
            const String ANNOTATED_MESSAGE = 'Info:  ' + MESSAGE;

            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_40);

            expect(logOnlyWithNameLengthBarelyOk.length, 1);
            expect(RegExp('^' + TIME_REGEX + ' ' + ANNOTATED_MESSAGE + '\$').hasMatch(logOnlyWithNameLengthBarelyOk[0]), isTrue);
        }));

        List<String> logOnlyWithNameLengthTooLong = [];
        test('Only with name, length too long', overridePrint(logOnlyWithNameLengthTooLong, ()
        async
        {
            // ignore: non_constant_identifier_names
            final String MESSAGE = 'GoogleAnalytics: ' + TEXT_41.substring(0, 40);
            // ignore: non_constant_identifier_names
            final String ANNOTATED_MESSAGE = 'Info:  ' + MESSAGE;

            IGoogleAnalyticsService analytics = await GoogleAnalyticsService.createMockable(MockFirebaseAnalytics(), true);
            analytics.track(TEXT_41);

            expect(logOnlyWithNameLengthTooLong.length, 1);
            expect(RegExp('^' + TIME_REGEX + ' ' + ANNOTATED_MESSAGE + '\$').hasMatch(logOnlyWithNameLengthTooLong[0]), isTrue);
        }));
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

overridePrint(List<String> log, testFunction())
{
    return ()
    {
        var specification = new ZoneSpecification(
            print: (_, __, ___, String msg)
            {
                // Add to log instead of printing to stdout
                log.add(msg);
            }
        );

        return Zone.current.fork(specification: specification).run(testFunction);
    };
}
