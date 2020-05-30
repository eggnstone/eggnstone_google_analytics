import 'package:eggnstone_flutter/services/analytics/IAnalyticsService.dart';

abstract class IGoogleAnalyticsService extends IAnalyticsService
{
    // TODO: shorten strings instead of expecting shortened strings

    void setUserProperty(String name, String value, {bool force = false});

    void setUserId(String value);
}
