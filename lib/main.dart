import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'noti.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void _checkLastActivity() async {
  print("CHECK LAST ACTIVITY");
  final prefs = await SharedPreferences.getInstance();
  final lastActivityTimestampString =
  prefs.getString('last_activity_timestamp');
  if (lastActivityTimestampString != null) {
    final lastActivityTimestamp = DateTime.parse(lastActivityTimestampString);
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastActivityTimestamp);
    if (difference.inMinutes >= 1440) {
      Noti.showBigTextNotification(
        title: "Reminder",
        body: "You haven't opened the app in 24 hours.",
        fln: flutterLocalNotificationsPlugin,
      );
    }
  }
}

void callbackDispatcher() {
  print("Call Back Dispatcher");
  Workmanager().executeTask((task, inputData) {
    _checkLastActivity();
    return Future.value(true);
  });
}

void _updateUserActivityTimestamp() async {
  print("UPDATE USER");
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('last_activity_timestamp', DateTime.now().toIso8601String());
}

void registerBackgroundTask() {
  print("REGISTER BACKGROUND TASK");
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    "background_task",
    initialDelay: Duration(seconds: 10),
    frequency: Duration(hours: 24),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _updateUserActivityTimestamp();
  registerBackgroundTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3ac3cb),
            Color(0xFFf85187)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blue.withOpacity(0.5),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            width: 200,
            height: 80,
            child: ElevatedButton(
              onPressed: () {
                Noti.showBigTextNotification(
                  title: "New message title",
                  body: "Your long body",
                  fln: flutterLocalNotificationsPlugin,
                );
              },
              child: Text("click"),
            ),
          ),
        ),
      ),
    );
  }
}
