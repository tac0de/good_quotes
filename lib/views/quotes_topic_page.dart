import 'dart:io';
import 'dart:ui';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instashare/instashare.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

import '../models/quote.dart';
import '../pref_provider.dart';
import '../widgets/theme_container.dart';

class QuotesTopicPage extends StatefulWidget {
  final String topicTitle;
  final fromReminder;
  final test;

  QuotesTopicPage(this.topicTitle, [this.fromReminder, this.test]);

  @override
  _QuotesTopicPageState createState() => _QuotesTopicPageState();
}

class _QuotesTopicPageState extends State<QuotesTopicPage> {
  bool isBack = true;
  bool isClicked = false;
  bool isLoading = false;
  ScreenshotController screenshotController = ScreenshotController();

  File _image;

  String clipboardText =
      "From the Good Quotes app @stoicquotes.today \n \n #quotes #goodquotes #motivation #qotd #quote #inspiration #quoteoftheday #motivationalquotes #dailyquotes #inspirational #quotestoliveby #mqapp1  #inspirationalquotes #instamotivation #instainspiration #instaquotes #motivationdaily #stoicquotes";

  _screenshotAndShareToInsta() async {
    FlutterClipboard.copy(clipboardText).then((result) {});
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Copied to your pasteboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Text and hashtags ready to be pasted in your caption.',
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
    if (_image != null) {
      await Instashare.shareToFeedInstagram(
        'image/*',
        _image.path,
      );
    }
  }

  // Take screenshot and share with default
  _screenshotAndShare() async {
    final RenderBox box = context.findRenderObject();

    if (_image.path != null) {
      await Share.shareFiles(
        [_image.path],
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: ThemeContainer(
        isBack: isBack,
        child: QuotesList(
          fromReminder: widget.test,
          quotes: widget.fromReminder,
          topicTitle: widget.topicTitle,
          controller: screenshotController,
          isBack: isBack,
          isLoading: isLoading,
          isClicked: isClicked,
          onShare: () {
            if (isClicked == false) {
              isClicked = true;
              setState(() {
                isBack = false;
              });
              screenshotController
                  .capture(
                pixelRatio: 2,
              )
                  .then((File image) async {
                setState(() {
                  _image = image;
                  isBack = true;
                });
                _screenshotAndShare();
                isClicked = false;
              });
              Future.delayed(Duration(milliseconds: 100)).then((_) {
                setState(() {
                  isLoading = true;
                });
              });
              Future.delayed(Duration(seconds: 1)).then((_) {
                setState(() {
                  isLoading = false;
                });
              });
            }
          },
          onShareToInsta: () {
            if (isClicked == false) {
              isClicked = true;
              setState(() {
                isBack = false;
              });
              screenshotController
                  .capture(
                pixelRatio: 2,
              )
                  .then((File image) async {
                var platformFile;
                if (Platform.isAndroid) {
                  Directory dir = await getExternalStorageDirectory();
                  dir.createSync();
                  File endFile = File("${dir.path}.jpg");
                  endFile.createSync();
                  endFile.writeAsBytesSync(image.readAsBytesSync());

                  setState(() {
                    platformFile = endFile;
                  });
                }

                setState(() {
                  _image = Platform.isIOS ? image : platformFile;
                  isBack = true;
                });

                _screenshotAndShareToInsta();
                isClicked = false;
              });

              Future.delayed(Duration(milliseconds: 100)).then((_) {
                setState(() {
                  isLoading = true;
                });
              });
              Future.delayed(Duration(seconds: 1)).then((_) {
                setState(() {
                  isLoading = false;
                });
              });
            }
          },
        ),
      ),
    );
  }
}

class QuotesList extends StatefulWidget {
  final List<Quote> quotes;
  final String topicTitle;
  final fromReminder;
  final bool isLoading;
  final bool isClicked;
  final ScreenshotController controller;
  final VoidCallback onShareToInsta;
  final VoidCallback onShare;
  final Function onPageChange;
  final bool isBack;

  QuotesList({
    Key key,
    this.quotes,
    this.fromReminder,
    this.topicTitle,
    this.isLoading,
    this.isClicked,
    this.controller,
    this.onShareToInsta,
    this.onShare,
    this.onPageChange,
    this.isBack,
  }) : super(key: key);

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  List quotes = [];

  @override
  void initState() {
    super.initState();

    widget.quotes.forEach((element) {
      if (element.topic == widget.topicTitle) {
        quotes.add(element);
      }
    });

    if (widget.topicTitle == "All") {
      setState(() {
        quotes = widget.quotes;
      });
    }

    if (widget.fromReminder == null) {
      quotes..shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PrefProvider>(context, listen: false);
    List _favQuotes = provider.favoriteQuotes;
    List _favAuthors = provider.favoriteAuthors;

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        print(quotes[index].author.runtimeType);
        bool alreadySaved =
            provider.favoriteQuotes.contains(quotes[index].quote);

        AppBar appbar = AppBar();

        return Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: appbar.preferredSize.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        quotes[index].quote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: quotes[index].quote.length > 150 ? 22 : 24,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      quotes[index].author,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            widget.isLoading
                ? Container(
                    height: 60,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Container(),
            Align(
              alignment: Alignment(0, 0.82),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    onPressed: widget.onShareToInsta,
                    icon: Icon(
                      MdiIcons.instagram,
                      color: widget.isBack ? Colors.white : Colors.transparent,
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    onPressed: widget.onShare,
                    icon: Icon(Icons.more_vert),
                    color: widget.isBack ? Colors.white : Colors.transparent,
                  ),
                  IconButton(
                    iconSize: 32,
                    onPressed: () {
                      setState(() {
                        if (!alreadySaved) {
                          _favQuotes.add(quotes[index].quote);
                          _favAuthors.add(quotes[index].author);
                        } else {
                          _favQuotes.remove(quotes[index].quote);
                          _favAuthors.remove(quotes[index].author);
                        }
                      });
                      provider.addToFavorite(_favQuotes, _favAuthors);
                    },
                    icon: Icon(
                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                      color: widget.isBack ? Colors.white : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      itemCount: quotes.length,
    );
  }
}
