import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_analytics/eggnstone_google_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main()
async
{
    final bool useLogger = true;
    // Use the following to only log in debug builds:
    //final bool useLogger = DartTools.isDebugBuild();

    final bool useAnalytics = true;
    // Use the following to only use analytics in release builds:
    //final bool useAnalytics = DartTools.isReleaseBuild();

    WidgetsFlutterBinding.ensureInitialized();

    try
    {
        await Firebase.initializeApp();
    }
    on Exception catch (e)
    {
        print(e);
        print('Download google-services.json from Firebase to android/app!');
        print('Download GoogleService-Info.plist from Firebase to ios/Runner!');
        return;
    }

    isLoggerEnabled = useLogger;

    final IGoogleAnalyticsService analytics = await GoogleAnalyticsService.create(useAnalytics);
    GetIt.instance.registerSingleton<IAnalyticsService>(analytics);
    analytics.track('AppStart', <String, dynamic>{'Version': '0.0.1'});

    runApp(App());
}

class App extends StatelessWidget
{
    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(
            title: 'eggnstone_google_analytics Demo',
            home: HomePage()
        );
    }
}

class HomePage extends StatefulWidget
{
    HomePage({Key key}) : super(key: key);

    @override
    _HomePageState createState()
    => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AnalyticsMixin
{
    int _counter = 0;

    void _incrementCounter()
    {
        setState(()
        {
            _counter++;
        });

        analytics.track('ButtonPush', <String, dynamic>{'Counter': _counter});
    }

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(title: Text('eggnstone_google_analytics Demo')),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text('You have pushed the button this many times:'),
                        Text('$_counter')
                    ]
                )
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: Icon(Icons.add)
            )
        );
    }
}
