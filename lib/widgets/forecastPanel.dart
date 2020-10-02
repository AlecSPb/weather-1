import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather/models/forecastModel.dart';
import 'package:weather/screens/homescreen.dart';

class ForecastPanel extends StatefulWidget {
  final List<ListElement> forecast;
  final bool isDayTime;
  final bool isMetric;
  ForecastPanel({this.forecast, this.isDayTime, this.isMetric});
  @override
  _ForecastPanelState createState() => _ForecastPanelState();
}

int selectedIndex;
PageController forecastDetailsController = new PageController();
double screenHeight;
double screenWidth;
double listheight;
var weather5Days;
var icon;

class _ForecastPanelState extends State<ForecastPanel> {
  Widget forecastDetail(int index) {
    var forecastList = widget.forecast;
    var tempCels = forecastList[index].main.temp - 273;

    var weather5Days = forecastList[index].weather[0].main;
    var dateTimeList2 = forecastList[index].dt;
    var timeFormat =
        new DateTime.fromMillisecondsSinceEpoch(dateTimeList2 * 1000);
    var time = DateFormat.j().format(timeFormat);
    var dateFormat =
        new DateTime.fromMillisecondsSinceEpoch(dateTimeList2 * 1000);
    var date = DateFormat.Md().format(dateFormat);

    var weatherDesc = forecastList[index].weather[0].description;

    var tempMax = forecastList[index].main.tempMax - 273;
    var tempMin = forecastList[index].main.tempMin - 273;
    var tempFeelsLike = forecastList[index].main.feelsLike - 273;
    var tempMaxFar = (forecastList[index].main.tempMax * (9 / 5)) - 459;
    var tempMinFar = (forecastList[index].main.tempMin * (9 / 5)) - 459;
    var tempFeelsLikeFar = (forecastList[index].main.feelsLike * (9 / 5)) - 459;
    var pressure = forecastList[index].main.pressure;
    var humidity = forecastList[index].main.humidity;
    var clouds = forecastList[index].clouds.all;
    var windSpd = forecastList[index].wind.speed * 3.6;
    var rainProb = forecastList[index].pop * 100;

    Map<String, dynamic> forecastDetailsMapMetric = {
      "MAX ": "${tempMax.round()}\u00B0",
      "MIN ": "${tempMin.round()}\u00B0",
      "FEELS LIKE": "${tempFeelsLike.round()}\u00B0",
      "PRESSURE": "$pressure hPa",
      "HUMIDITY": "$humidity%",
      "CLOUDS": "$clouds%",
      "WIND SPEED": widget.isMetric
          ? "${windSpd.toStringAsFixed(2)} km/h"
          : "${(windSpd / 1.7).toStringAsFixed(2)} mph",
      "CHANCE OF RAIN": "${rainProb.toStringAsFixed(0)}%",
    };
    final detailNameMetric = forecastDetailsMapMetric.keys.toList();
    final detailMetric = forecastDetailsMapMetric.values.toList();

    Map<String, dynamic> forecastDetailsMapImp = {
      "MAX ": "${tempMaxFar.round()}\u00B0",
      "MIN ": "${tempMinFar.round()}\u00B0",
      "FEELS LIKE": "${tempFeelsLikeFar.round()}\u00B0",
      "PRESSURE": "$pressure hPa",
      "HUMIDITY": "$humidity%",
      "CLOUDS": "$clouds%",
      "WIND SPEED": "${windSpd.toStringAsFixed(2)} km/h",
      "CHANCE OF RAIN": "${rainProb.toStringAsFixed(0)}%",
    };
    final detailNameImp = forecastDetailsMapImp.keys.toList();
    final detailImp = forecastDetailsMapImp.values.toList();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.3,
        ),
        itemCount: forecastDetailsMapMetric.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.only(left: 8, top: 7),
            child: Container(
              //color: Colors.pink,
              child: Container(
                width: 40,
                //color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detailNameMetric[index].toString(),
                      style: GoogleFonts.quicksand(
                        color: widget.isDayTime
                            ? Colors.amber[700]
                            : Colors.deepPurple[800],
                        fontSize: screenHeight * 0.015,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      detailMetric[index].toString(),
                      style: GoogleFonts.quicksand(
                        color: widget.isDayTime
                            ? Colors.amber[700]
                            : Colors.deepPurple[800],
                        fontSize: screenHeight * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget forecastTile(index) {
    var forecastList = widget.forecast;
    var dateTimeList2 = forecastList[index].dt;
    var timeFormat =
        new DateTime.fromMillisecondsSinceEpoch(dateTimeList2 * 1000);
    var time = DateFormat.j().format(timeFormat);
    var dateFormat =
        new DateTime.fromMillisecondsSinceEpoch(dateTimeList2 * 1000);
    var date = DateFormat.Md().format(dateFormat);
    var tempCels = forecastList[index].main.temp - 273;
    weather5Days = forecastList[index].weather[0].main;
    var tempFar = (forecastList[index].main.temp * (9 / 5)) - 459;

    Map<String, dynamic> weatherIcon = {
      "Rain": FeatherIcons.cloudDrizzle,
      "Clouds": FeatherIcons.cloud,
    };

    final icons = weatherIcon.values.toList();

    return Container(
      height: 100,
      width: 60,
      decoration: BoxDecoration(
        color: widget.isDayTime
            ? selectedIndex == index ? Colors.amber[500] : Colors.amber[200]
            : selectedIndex == index
                ? Colors.deepPurple[400]
                : Colors.deepPurple[200],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.09),
          bottom: Radius.circular(screenWidth * 0.09),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text(tempInt().toString()),
            //Text(dataList[index]["main"]["temp"].toString()),
            Container(
              child: Text(
                date,
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: listheight * 0.10,
                ),
              ),
            ),
            Container(
              //padding: EdgeInsets.only(
              // bottom: screenHeight * 0.01358),
              child: Text(
                time,
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: listheight * 0.11,
                ),
              ),
            ),
            /*Container(
              child: Text(
                "$weather5Days",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  //fontSize: screenHeight * 0.034,
                  fontSize: listheight * 0.13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),*/
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 2,
              ),
              child: Icon(
                weather5Days == "Rain"
                    ? FeatherIcons.cloudDrizzle
                    : FeatherIcons.cloud,
                color: Colors.white,
                size: 23,
              ),
            ),

            Container(
              child: Text(
                isMetric
                    ? "${tempCels.round().toString()}\u00B0"
                    : "${tempFar.round().toString()}\u00B0",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  //fontSize: screenHeight * 0.034,
                  fontSize: listheight * 0.15,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //Text(now.toString()),
          ],
        ),
      ),
    );
  }

  void pageChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onTapped(int index) {
    forecastDetailsController.animateToPage(
      index,
      duration: Duration(milliseconds: 750),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    listheight = screenHeight * 0.17;
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: 5,
            onPageChanged: pageChange,
            controller: forecastDetailsController,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.only(top: 60, left: 20),
                child: forecastDetail(index),
              );
            },
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              height: listheight,
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      onTapped(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: forecastTile(index),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 1,
            left: 130,
            child: Container(
              child: Center(
                child: Container(
                  height: 4,
                  width: 100,
                  decoration: BoxDecoration(
                    color: widget.isDayTime
                        ? Colors.amber
                        : Colors.deepPurple[800],
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
