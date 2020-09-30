import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/models/forecastModel.dart';
import 'dailyForecastModel.dart';
import 'weatherModel.dart';

class Services {
  static Future<Position> getPosition() async {
    try {
      final position =
          await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;
    } catch (e) {}
  }

  static Future<GetWeatherClass> getWeather(
      double lat, double lon, String apiKey) async {
    final response = await http.get(
        'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey');
    final GetWeatherClass results = getWeatherClassFromJson(response.body);

    //double temp = results.main.temp;
    return results;
  }

  static Future<List<ListElement>> getForecastList(
      double lat, double lon, String apiKey) async {
    final response = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey');
    final results = getForecastClassFromJson(response.body);

    List<ListElement> list = results.list;
    return list;
  }

  static Future<List<Daily>> getDailyForecastList(
      double lat, double lon, String apiKey) async {
    final response = await http.get(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=hourly,minutely,current&appid=$apiKey');

    final results = getDailyForecastClassFromJson(response.body);

    List<Daily> dailyList = results.daily;
    return dailyList;
  }
}
