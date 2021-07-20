import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:good_quotes/widgets/premium_modal.dart';

import 'package:provider/provider.dart';

import '../main.dart';
import '../pref_provider.dart';
import '../widgets/theme_container.dart';
import 'add_reminder_page.dart';

class ReminderPage extends StatefulWidget {
  final randomOne;
  final isShuffled;

  ReminderPage([this.randomOne, this.isShuffled]);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  int newIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PrefProvider>(context, listen: false);

    List<String> reminderTimes = provider.reminderTimes;
    AppBar appBar = AppBar();

    var alertText = TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    return ThemeContainer(
      opacity: !provider.isPurchased ? 0.7 : 0.35,
      appTitle: Text(
        'Reminders'.toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(255, 255, 255, 0.9),
          letterSpacing: 7,
        ),
      ),
      child: !provider.isPurchased
          ? Stack(children: [
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: appBar.preferredSize.height,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 42,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'This is a premium feature',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(
                  0,
                  0.3,
                ),
                child: SizedBox(
                  width: 220,
                  height: 60,
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    color: Color(0xffFfe6746),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () {
                      return showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          builder: (context) {
                            return PremiumModal();
                          });
                    },
                    child: Text(
                      'Buy premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (context, index) {
                  newIndex = index;
                  return ListTile(
                    contentPadding: EdgeInsets.all(15),
                    onTap: () {},
                    title: Text(
                      '9:00 AM',
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white38,
                      ),
                    ),
                  );
                },
              )
            ])
          : Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: reminderTimes.length,
                  itemBuilder: (context, index) {
                    newIndex = index;
                    return ListTile(
                      contentPadding: EdgeInsets.all(15),
                      onTap: () {},
                      title: Text(reminderTimes[index]),
                      trailing: IconButton(
                        onPressed: () {
                          flutterLocalNotificationsPlugin.cancel(index);
                          setState(() {
                            reminderTimes.removeAt(index);
                          });
                          provider.addToReminder(reminderTimes);
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                InkWell(
                  onTap: () {
                    if (reminderTimes.length > 0 &&
                        provider.isPurchased == false) {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        builder: (context) {
                          return PremiumModal();
                        },
                      );
                    } else {
                      if (reminderTimes.length >= 5) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Platform.isAndroid
                                ? AlertDialog(
                                    content: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'You cannot add more reminders.',
                                        textAlign: TextAlign.center,
                                        style: alertText,
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
                                        'You cannot add more reminders.',
                                        textAlign: TextAlign.center,
                                        style: alertText,
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddReminderPage(
                              widget.randomOne,
                              widget.isShuffled,
                              newIndex,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    "Add Reminder",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30),
                  ),
                )
              ],
            ),
    );
  }
}
