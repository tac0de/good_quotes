import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pref_provider.dart';
import '../views/quotes_page.dart';

class ThemeContainer extends StatefulWidget {
  final Widget child;
  final Widget appTitle;
  final appBarIcon;
  final bool isBack;
  final bool isHome;
  final bool toQuotesPage;
  final double opacity;

  ThemeContainer({
    @required this.child,
    this.appTitle,
    this.appBarIcon,
    this.isBack = true,
    this.isHome = false,
    this.toQuotesPage = false,
    this.opacity = 0.35,
  });

  @override
  _ThemeContainerState createState() => _ThemeContainerState();
}

class _ThemeContainerState extends State<ThemeContainer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrefProvider>(
      builder: (context, notifier, child) {
        return Container(
          decoration: notifier.bgTheme == null || notifier.bgTheme == ""
              ? BoxDecoration(color: Colors.black)
              : BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      notifier.bgTheme,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
          child: Stack(
            children: [
              Container(
                color: Color.fromRGBO(
                  0,
                  0,
                  0,
                  widget.opacity,
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leading: !widget.isHome
                      ? IconButton(
                          color:
                              widget.isBack ? Colors.white : Colors.transparent,
                          icon: Icon(
                            Icons.arrow_back,
                          ),
                          onPressed: () {
                            if (widget.toQuotesPage) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => QuotesPage()));
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      : null,
                  title: widget.appTitle,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  elevation: 0,
                  actions: widget.appBarIcon,
                ),
                body: widget.child,
              )
            ],
          ),
        );
      },
    );
  }
}
