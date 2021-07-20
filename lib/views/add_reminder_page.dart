import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../pref_provider.dart';
import '../widgets/theme_container.dart';

class AddReminderPage extends StatefulWidget {
  final randomOne;
  final isShuffled;
  final index;

  AddReminderPage([this.randomOne, this.isShuffled, this.index]);

  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  var _dateTime;
  bool isShuffled;

  List<String> modifiedWeeks = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  List<String> weeks = [
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
    "S",
  ];

  List<String> displayedWeeks = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  List<bool> isWeeks = [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
  ];

  void _showNotification() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Platform.isAndroid
            ? AlertDialog(
                title: Builder(
                  builder: (context) {
                    var height = MediaQuery.of(context).size.height;

                    return Container(
                      child: Center(
                        child: Text(
                          'Reminder Added',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Builder(
                  builder: (context) {
                    var height = MediaQuery.of(context).size.height;

                    return Container(
                      height: height - 820,
                      child: Center(
                        child: Text(
                          'Reminder Added',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
      },
    );
    await notification();
  }

  Future<void> notification() async {
    var time = Time(_dateTime.hour, _dateTime.minute);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_quotes',
      'daily_quotes',
      'Channel for Daily quotes',
      icon: 'app_icon',
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      importance: Importance.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      widget.index,
      'Quotes Reminder',
      'Your daily quotes has arrived',
      time,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PrefProvider>(context, listen: false);

    return ThemeContainer(
      appTitle: Text(
        'Add Reminder'.toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(255, 255, 255, 0.9),
          letterSpacing: 7,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: TimePickerSpinner(
                  time: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day, 9, 0),
                  normalTextStyle:
                      TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
                  highlightedTextStyle: TextStyle(color: Colors.white),
                  spacing: 50,
                  itemHeight: 80,
                  is24HourMode: false,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      _dateTime = time;
                    });
                  },
                ),
              ),
              SizedBox(height: 50),
              InkWell(
                onTap: () async {
                  if (provider.reminderTimes
                      .contains('${DateFormat.jm().format(_dateTime)}')) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Platform.isAndroid
                            ? AlertDialog(
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Reminder with the same time exists.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "Ok");
                                    },
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CupertinoAlertDialog(
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Reminder with the same time exists.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "Ok");
                                    },
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      },
                    );
                  } else {
                    if (provider.reminderTimes.length < 5) {
                      _showNotification();
                      provider.reminderTimes
                          .add('${DateFormat.jm().format(_dateTime)}');
                      provider.addToReminder(provider.reminderTimes);
                    }
                  }
                },
                child: Text(
                  "Set Reminder",
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
