import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather/models/weatherModel.dart';

class CurrentWeatherDetails extends StatefulWidget {
  final GetWeatherClass currentWeather;
  CurrentWeatherDetails({this.currentWeather});

  @override
  _CurrentWeatherDetailsState createState() => _CurrentWeatherDetailsState();
}

class _CurrentWeatherDetailsState extends State<CurrentWeatherDetails> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    var weather = widget.currentWeather;
    var pressure = weather.main.pressure;
    var humidity = weather.main.humidity;
    var sunRise = weather.sys.sunrise;
    var sunSet = weather.sys.sunset;
    var windSpd = weather.wind.speed * 3.6;
    var clouds = weather.clouds.all;

    var sunRiseConvert =
        new DateTime.fromMillisecondsSinceEpoch(sunRise * 1000);
    var sunRiseTime = DateFormat.jm().format(sunRiseConvert);

    var sunSetConvert = new DateTime.fromMillisecondsSinceEpoch(sunSet * 1000);
    var sunSetTime = DateFormat.jm().format(sunSetConvert);

    Map<String, dynamic> currentWeatherMap = {
      "SUNRISE": "$sunRiseTime",
      "SUNSET": "$sunSetTime",
      "PRESSURE": "$pressure hPa",
      "HUMIDITY": "$humidity%",
      "WIND SPEED": "${windSpd.toStringAsFixed(2)} km/h",
      "CLOUDS": "$clouds%",
    };

    final detailName = currentWeatherMap.keys.toList();
    final detail = currentWeatherMap.values.toList();

    return Container(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 20,
        ),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.3,
        ),
        itemCount: currentWeatherMap.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      detailName[index].toString(),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: screenHeight * 0.015,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      detail[index].toString(),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: screenHeight * 0.032,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
