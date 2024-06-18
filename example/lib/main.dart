import 'package:eggnstone_dart/eggnstone_dart.dart';
import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_analytics/eggnstone_google_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> main()
async
{
    // ignore: prefer_const_declarations
    final bool useLogger = true;
    // Use the following to only log in debug builds:
    //final bool useLogger = DartTools.isDebugBuild();

    // ignore: prefer_const_declarations
    final bool useAnalytics = true;
    // Use the following to only use analytics in release builds:
    //final bool useAnalytics = DartTools.isReleaseBuild();

    // ignore: prefer_const_declarations
    final bool debugAnalytics = true;

    WidgetsFlutterBinding.ensureInitialized();

    try
    {
        await Firebase.initializeApp();
    }
    on Exception catch (e)
    {
        // ignore: avoid_print
        print(e);
        // ignore: avoid_print
        print('Download google-services.json from Firebase to android/app!');
        // ignore: avoid_print
        print('Download GoogleService-Info.plist from Firebase to ios/Runner!');
        return;
    }

    isLoggerEnabled = useLogger;

    final IGoogleAnalyticsService analytics = await GoogleAnalyticsService.create(useAnalytics, debugAnalytics);
    GetIt.instance.registerSingleton<IAnalyticsService>(analytics);
    analytics.track('AppStart', <String, Object>{'Version': '0.0.1'});

    runApp(const App());
}

class App extends StatelessWidget
{
    const App({super.key});

    @override
    Widget build(BuildContext context)
    // ignore: prefer_expression_function_bodies
    {
        return const MaterialApp(
            title: 'eggnstone_google_analytics Demo',
            home: HomePage()
        );
    }
}

class HomePage extends StatefulWidget
{
    const HomePage({super.key});

    @override
    // ignore: library_private_types_in_public_api
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

        analytics.track('ButtonPush', <String, Object>{'Counter': _counter});
    }

    @override
    Widget build(BuildContext context)
    // ignore: prefer_expression_function_bodies
    {
        return Scaffold(
            appBar: AppBar(title: const Text('eggnstone_google_analytics Demo')),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        const Text('You have pushed the button this many times:'),
                        Text('$_counter')
                    ]
                )
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add)
            )
        );
    }
}
