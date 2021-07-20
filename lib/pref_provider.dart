import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefProvider extends ChangeNotifier {
  SharedPreferences _prefs;

  List _favoriteQuotes = [];
  List _favoriteAuthors = [];

  List _reminderTimes = [];

  String _bgTheme;

  bool _isPurchased;

  List get favoriteQuotes => _favoriteQuotes;
  List get favoriteAuthors => _favoriteAuthors;
  List get reminderTimes => _reminderTimes;
  String get bgTheme => _bgTheme;
  bool get isPurchased => _isPurchased;

  PrefProvider() {
    _loadTheme();
    _loadPurchase();
    _loadFavoriteQuotes();
    _loadFavoriteAuthors();
    _loadReminderTimes();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadPurchase() async {
    await _initPrefs();
    _isPurchased = (_prefs.getBool("isPurchased") ?? false);
    notifyListeners();
  }

  _savePurchase() async {
    await _initPrefs();
    _prefs.setBool('isPurchased', _isPurchased);
  }

  doPurchase() {
    _isPurchased = true;
    _savePurchase();
    notifyListeners();
  }

  _loadTheme() async {
    await _initPrefs();
    _bgTheme = (_prefs.getString("bgTheme") ?? "assets/images/theme-1.jpg");
    notifyListeners();
  }

  _saveTheme() async {
    await _initPrefs();
    _prefs.setString('bgTheme', _bgTheme);
  }

  _loadFavoriteQuotes() async {
    await _initPrefs();
    _favoriteQuotes =
        (_prefs.getStringList("favoriteQuotes") ?? List<String>());
    notifyListeners();
  }

  _saveFavoriteQuotes() async {
    await _initPrefs();
    _prefs.setStringList('favoriteQuotes', _favoriteQuotes);
  }

  _loadFavoriteAuthors() async {
    await _initPrefs();
    _favoriteAuthors =
        (_prefs.getStringList("favoriteAuthors") ?? List<String>());
    notifyListeners();
  }

  _saveFavoriteAuthors() async {
    await _initPrefs();
    _prefs.setStringList('favoriteAuthors', _favoriteAuthors);
  }

  _loadReminderTimes() async {
    await _initPrefs();

    _reminderTimes = (_prefs.getStringList("reminderTimes") ?? List<String>());
    notifyListeners();
  }

  _saveReminderTimes() async {
    await _initPrefs();
    _prefs.setStringList('reminderTimes', _reminderTimes);
  }

  changeBgTheme(bg) {
    _bgTheme = bg;
    _saveTheme();
    notifyListeners();
  }

  addToFavorite(quote, author) {
    _favoriteQuotes = quote;
    _favoriteAuthors = author;
    _saveFavoriteQuotes();
    _saveFavoriteAuthors();
    notifyListeners();
  }

  addToReminder(time) {
    _reminderTimes = time;
    _saveReminderTimes();
    notifyListeners();
  }
}
