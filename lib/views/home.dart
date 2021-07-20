import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/quote.dart';
import '../widgets/theme_container.dart';
import 'quotes_page.dart';
import 'quotes_topic_page.dart';
import 'reminder_page.dart';
import 'settings_page.dart';
import 'themes_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var firstQuote;
  var oldlyQuote;
  bool isShuffled = false;

  @override
  void initState() {
    super.initState();
    selectNotificationSubject.stream.listen((String payload) async {
      await Future.delayed(Duration(milliseconds: 300)).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => QuotesTopicPage(
              "All",
              firstQuote,
            ),
          ),
        );
      });
    });

    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => QuotesTopicPage(
                      "All",
                      firstQuote,
                    ),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeContainer(
        isHome: true,
        appTitle: Text(
          'Good Quotes'.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            color: Color.fromRGBO(255, 255, 255, 0.9),
            letterSpacing: 7,
          ),
        ),
        child: FutureBuilder(
          future: fetchQuotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              firstQuote = snapshot.data;
            }
            return ListView(
              padding: EdgeInsets.only(top: 30),
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  title: Text(
                    'Quotes',
                    style: TextStyle(letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    if (snapshot.hasData)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuotesPage(firstQuote),
                        ),
                      );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  title: Text(
                    'Themes',
                    style: TextStyle(letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    if (snapshot.hasData)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ThemesPage(),
                        ),
                      );
                  },
                ),
                ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    title: Text(
                      'Reminders',
                      style: TextStyle(letterSpacing: 2),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      if (snapshot.hasData)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ReminderPage(firstQuote, isShuffled),
                          ),
                        );
                    }),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  onTap: () {
                    if (snapshot.hasData)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                  },
                  title: Text(
                    'Settings',
                    style: TextStyle(letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ));
  }
}
