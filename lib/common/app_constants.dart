// ignore_for_file: file_names

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/db/app_database.dart';

import '../features/language/domain/models/language_listing_model.dart';
import 'dart:io';

class AppConstants {
  static const String title = 'Book2go AT raid';
  static const String baseUrl = 'https://noyoevindia.com/';
  static String firbaseApiKey = (Platform.isAndroid)
      ? "AIzaSyAtIM6YgS0E-kICtG3DWAXa5dqstoelUD0"
      : "ios firebase api key";
  static String firebaseAppId = (Platform.isAndroid)
      ? "1:278233606273:android:8c38ed5f6fbd96b3150580"
      : "ios firebase app id";
  static String firebasemessagingSenderId =
      (Platform.isAndroid) ? "278233606273" : "ios firebase sender id";
  static String firebaseProjectId =
      (Platform.isAndroid) ? "noyo-app" : "ios firebase project id";

  static String mapKey = (Platform.isAndroid)
      ? 'AIzaSyC8ajlcg9UzcHWmFjHfNenSynk6VCSlyhU'
      : 'ios map key';
  static const String privacyPolicy = 'your privacy policy url';
  static const String termsCondition = 'your terms and condition url';

  static const String stripPublishKey = '';

  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'Azerbaijani', lang: 'az'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es'),
  ];

  static LatLng currentLocations = const LatLng(0, 0);
}

AppDatabase db = AppDatabase();
bool isAppMapChange = false;
