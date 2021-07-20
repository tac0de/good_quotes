import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instashare/instashare.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

import '../pref_provider.dart';
import '../widgets/theme_container.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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
    if (_image.path != null) {
      await Instashare.shareToFeedInstagram(
        "image/*",
        _image.path,
      );
    }
  }

  _screenshotAndShare() async {
    final RenderBox box = context.findRenderObject();

    if (_image.path != null) {
      await Share.shareFiles([_image.path],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PrefProvider>(context, listen: false);

    List quotes = provider.favoriteQuotes;

    List authors = provider.favoriteAuthors;

    return Screenshot(
      controller: screenshotController,
      child: ThemeContainer(
        isBack: isBack,
        child: quotes.length == 0
            ? Center(
                child: Text(
                  "No favorite quotes",
                  style: TextStyle(fontSize: 30),
                ),
              )
            : PageView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  quotes[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        quotes[index].length > 150 ? 22 : 24,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                authors[index],
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
                      isLoading
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
                              onPressed: () {
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
                                      Directory dir =
                                          await getExternalStorageDirectory();
                                      dir.createSync();
                                      File endFile = File("${dir.path}.jpg");
                                      endFile.createSync();
                                      endFile.writeAsBytesSync(
                                          image.readAsBytesSync());

                                      setState(() {
                                        platformFile = endFile;
                                      });
                                    }

                                    setState(() {
                                      _image =
                                          Platform.isIOS ? image : platformFile;
                                      isBack = true;
                                    });
                                    _screenshotAndShareToInsta();
                                    isClicked = false;
                                  });
                                  Future.delayed(Duration(milliseconds: 100))
                                      .then((_) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                  });
                                  Future.delayed(Duration(seconds: 1))
                                      .then((_) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                }
                              },
                              icon: Icon(
                                MdiIcons.instagram,
                                color:
                                    isBack ? Colors.white : Colors.transparent,
                              ),
                            ),
                            IconButton(
                              iconSize: 32,
                              onPressed: () {
                                if (isClicked == false) {
                                  isClicked = true;
                                  setState(() {
                                    isBack = false;
                                  });
                                  screenshotController
                                      .capture(
                                    pixelRatio: 2,
                                  )
                                      .then((File image) {
                                    setState(() {
                                      _image = image;
                                      isBack = true;
                                    });
                                    _screenshotAndShare();
                                    isClicked = false;
                                  });
                                  Future.delayed(Duration(milliseconds: 100))
                                      .then((_) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                  });
                                  Future.delayed(Duration(seconds: 1))
                                      .then((_) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.more_vert,
                                color:
                                    isBack ? Colors.white : Colors.transparent,
                              ),
                            ),
                            IconButton(
                              iconSize: 32,
                              onPressed: () {
                                setState(() {
                                  quotes.removeAt(index);
                                  authors.removeAt(index);
                                });
                                provider.addToFavorite(quotes, authors);
                              },
                              icon: Icon(
                                Icons.favorite,
                                color:
                                    isBack ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                itemCount: quotes.length,
              ),
      ),
    );
  }
}
