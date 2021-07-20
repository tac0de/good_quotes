import 'package:flutter/material.dart';
import 'package:good_quotes/widgets/premium_modal.dart';
import 'package:provider/provider.dart';

import '../pref_provider.dart';

class ThemesPage extends StatefulWidget {
  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  List<String> bgThemes = [];
  List<String> bgThumbs = [];

  @override
  void initState() {
    super.initState();
    for (var i = 1; i < 43; i++) {
      bgThemes.add('assets/images/theme-$i.jpg');
      bgThumbs.add('assets/images/thumbnails/theme-thumb-$i.jpg');
    }

    imageCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefProvider>(
      builder: (context, notifier, child) {
        return Container(
          color: Colors.black,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                'Themes'.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  letterSpacing: 7,
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      children: bgThemes.asMap().entries.map((image) {
                        return InkWell(
                          onTap: () {
                            if (image.key == 0 ||
                                image.key == 1 ||
                                image.key == 2 ||
                                image.key == 3 ||
                                notifier.isPurchased) {
                              notifier.changeBgTheme(image.value);
                            } else {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                builder: (context) => PremiumModal(),
                              );
                            }
                          },
                          child: GridTile(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(bgThumbs[image.key]),
                                  fit: BoxFit.cover,
                                  colorFilter: image.key != 0 && image.key != 1
                                      ? ColorFilter.mode(
                                          Colors.black.withOpacity(0.3),
                                          BlendMode.darken)
                                      : null,
                                ),
                              ),
                              child: image.key != 0 &&
                                      image.key != 1 &&
                                      image.key != 2 &&
                                      image.key != 3 &&
                                      notifier.isPurchased == false
                                  ? Icon(Icons.lock,
                                      color: Colors.white, size: 30)
                                  : notifier.bgTheme == image.value
                                      ? Icon(Icons.check_circle,
                                          color: Colors.white)
                                      : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
