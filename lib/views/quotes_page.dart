import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/theme_container.dart';
import 'favorites_page.dart';
import 'quotes_topic_page.dart';

class QuotesPage extends StatefulWidget {
  final firstQuote;

  QuotesPage([this.firstQuote]);

  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);
  var initialQuote;
  @override
  void initState() {
    super.initState();
    setState(() {
      initialQuote = widget.firstQuote;
    });
  }

  final List<dynamic> topics = [
    "Favorites",
    "All",
    "Motivational",
    "Positive",
    "Inspirational",
    "Life",
    "Attitude",
    "Beauty",
    "Love",
    "Smile",
    "Funny",
    "Wisdom",
  ];

  @override
  Widget build(BuildContext context) {
    return ThemeContainer(
      appTitle: Text(
        "Quotes".toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          letterSpacing: 7,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: CupertinoScrollbar(
          controller: _scrollController,
          isAlwaysShown: true,
          child: ListView(
            controller: _scrollController,
            children: topics.map((topic) {
              return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  title: Text(
                    topic,
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 2),
                  ),
                  onTap: () {
                    topic == "Favorites"
                        ? Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FavoritesPage(),
                            ),
                          )
                        : Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuotesTopicPage(topic, widget.firstQuote),
                            ),
                          );
                  });
            }).toList(),
          ),
        ),
      ),
    );
  }
}
