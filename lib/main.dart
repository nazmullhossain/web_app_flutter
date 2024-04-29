import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_ksa/firebase_options.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/home.dart';

import 'app/services/analytic_engin.dart';
import 'notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  AnalyticEngin.appOpen();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    NotificationService().listenNotifications();
  }
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // textTheme: TextTheme(),
      ),
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics: service.analytics),
      // ],
      home: const HomeScreen(),
    );
  }
}
