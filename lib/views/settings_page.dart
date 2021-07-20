import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:good_quotes/pref_provider.dart';
import 'package:good_quotes/widgets/donate_modal.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/donate_modal.dart';
import '../widgets/premium_modal.dart';
import '../widgets/theme_container.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PrefProvider>(context, listen: false);

    return ThemeContainer(
      appTitle: Text(
        "Settings".toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          letterSpacing: 7,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.only(top: 30),
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            title: Text(
              'Premium',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 2),
            ),
            onTap: provider.isPurchased == true
                ? () async {
                    var alertText = TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    );

                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Platform.isAndroid
                            ? AlertDialog(
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Already purchased',
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
                                    'Already purchased',
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
                  }
                : () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    builder: (context) {
                      return PremiumModal();
                    }),
          ),
          // ListTile(
          //   contentPadding: EdgeInsets.symmetric(vertical: 15),
          //   title: Text(
          //     'Donate',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(letterSpacing: 2),
          //   ),
          //   onTap: () => showModalBottomSheet(
          //     isScrollControlled: true,
          //     context: context,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     builder: (context) {
          //       return DonateModal();
          //     },
          //   ),
          // ),
          ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 15),
              title: Text(
                'Leave us a review',
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 2),
              ),
              onTap: () {
                final InAppReview _inAppReview = InAppReview.instance;

                _inAppReview.openStoreListing(
                  appStoreId: "1548627443",
                );
              }),
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            title: Text(
              'Give us a feedback',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 2),
            ),
            onTap: () {
              launch('mailto:jasonchoiseoul@gmail.com');
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            title: Text(
              'Instagram',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 2),
            ),
            onTap: () {
              launch(
                'https://www.instagram.com/stoicquotes.today/',
                forceSafariVC: false,
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            title: Text(
              'Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 2),
            ),
            onTap: () {
              launch(
                'https://github.com/tac0de/privacy-policy-for-good-quotes/blob/main/README.md',
                forceSafariVC: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
