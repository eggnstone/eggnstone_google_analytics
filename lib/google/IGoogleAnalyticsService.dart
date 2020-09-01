import 'package:eggnstone_flutter/eggnstone_flutter.dart';

abstract class IGoogleAnalyticsService extends IAnalyticsService
{
    // TODO: shorten strings instead of expecting shortened strings

    void setUserProperty(String name, String value, {bool force = false});

    void setUserId(String value);
}
