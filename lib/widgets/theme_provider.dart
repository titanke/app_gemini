import 'package:flutter/material.dart';
import 'package:app_gemini/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  //themes
    bool _isDarkTheme = false;

  ThemeProvider() {
    _loadThemeFromSharedPreferences();
    loadFavorites();
     _loadLocale();
  }
  ThemeData get themeData => _isDarkTheme ? darkMode : lightMode;

  bool get isDarkTheme => _isDarkTheme;

  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
    _saveThemeToSharedPreferences(value);
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    _saveThemeToSharedPreferences(_isDarkTheme);
  }

  Future<void> _saveThemeToSharedPreferences(bool isDarkTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  Future<void> _loadThemeFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }
//favorites 
  List<String> _favoriteTopics = [];

  List<String> get favoriteTopics => _favoriteTopics;

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favoriteTopics');
    if (savedFavorites != null) {
      _favoriteTopics = savedFavorites;
      notifyListeners();
    }
  }

  Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteTopics', _favoriteTopics);
  }

  set favoriteTopics(List<String> value) {
    _favoriteTopics = value;
    notifyListeners();
  }

  void addFavoriteTopic(String topicId) {
    _favoriteTopics.add(topicId);
    notifyListeners();
    saveFavorites(); 
  }

  void removeFavoriteTopic(String topicId) {
    _favoriteTopics.remove(topicId);
    notifyListeners();
    saveFavorites(); 
  }
  
  //languaje
  Locale _locale = Locale('es', 'ES');


  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale') ?? 'en_US';
    final localeList = localeCode.split('_');
    _locale = Locale(localeList[0], localeList[1]);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
    notifyListeners();
  }
}
