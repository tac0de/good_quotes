import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

import 'pref_provider.dart';
import 'views/home.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidInitializationSettings androidInitializationSettings;
IOSInitializationSettings iosInitializationSettings;
InitializationSettings initializationSettings;

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Local notification initialization
  var initializationSettingsAndroid = AndroidInitializationSettings(
    'app_icon',
  );

  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
  );

  var initializationSettings = InitializationSettings(
    initializationSettingsAndroid,
    initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      selectNotificationSubject.add(payload);
    },
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool ipadData = false;

  @override
  void initState() {
    super.initState();
    isIpad();
  }

  Future<void> isIpad() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    setState(() {
      ipadData = false;
    });
    if (info.model.toLowerCase().contains("ipad")) {
      setState(() {
        ipadData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrefProvider(),
      child: Consumer<PrefProvider>(
        builder: (context, notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Good Quotes",
            theme: ThemeData(
              splashColor: Colors.transparent,
              fontFamily: 'Garamond',
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Garamond',
                    fontSizeFactor: 1.6,
                    bodyColor: Color.fromRGBO(255, 255, 255, 0.9),
                  ),
              accentColor: Colors.white,
            ),
            home: Home(),
            builder: (context, child) {
              return MediaQuery(
                child: child,
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: Platform.isAndroid
                      ? 0.875
                      : ipadData
                          ? 1.4
                          : 1,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
