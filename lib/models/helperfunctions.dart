import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String isMetricKey;

  static Future<bool> saveUnitPreference(bool isMetric) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isMetricKey, isMetric);
  }

  static Future<bool> getUnitPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isMetricKey);
  }
}
