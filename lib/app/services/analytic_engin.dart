import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticEngin {
  static final _instance = FirebaseAnalytics.instance;

  static void appOpen() async {
    await _instance.logAppOpen();
  }

  static void eventLogin(String loginMethod) async {
    await _instance.logLogin(loginMethod: loginMethod);
  }

  static void eventLog(String name) async {
    await _instance.logEvent(name: name);
  }
}