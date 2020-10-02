import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:weather/models/dailyForecastModel.dart';
import 'package:weather/models/weatherModel.dart';
import 'package:weather/models/weatherservices.dart';
import 'package:weather/screens/noInternetScreen.dart';

class DailyForecast extends StatefulWidget {
  String areaName;
  bool isDayTime;
  final onRefresh;
  final bool isMetric;
  DailyForecast({this.areaName, this.isDayTime, this.onRefresh, this.isMetric});
  @override
  _DailyForecastState createState() => _DailyForecastState();
}

double screenHeight;
double screenWidth;
String dailyDayDate;

bool isLoading;
bool isConnected;
String status;
bool hasInternet;

Position position;
double lat;
double lon;

List<Daily> dailyList;

var icon;

GetWeatherClass currentWeather;

String apiKey = '53862ec8ca1bbd0799c36df21326f30f';

class _DailyForecastState extends State<DailyForecast> {
  RefreshController refreshController =
      new RefreshController(initialRefresh: false);
  Widget dailyForecastList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 7,
      itemBuilder: (BuildContext context, int index) {
        int start = index + 1;
        var dateTime = dailyList[start].dt;
        var _weather = dailyList[start].weather[0].main;
        var _dailyMax = widget.isMetric
            ? dailyList[start].temp.max - 273
            : (dailyList[start].temp.max * (9 / 5) - 459).round();
        var _dailyMin = widget.isMetric
            ? dailyList[start].temp.min - 273
            : (dailyList[start].temp.min * (9 / 5) - 459).round();
        var date = new DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
        var dateFinal = DateFormat.Md().format(date);
        dailyDayDate = DateFormat.E().format(date);

        var sunrise = dailyList[start].sunrise;
        var sunset = dailyList[start].sunset;
        var pressure = dailyList[start].pressure;
        var humidity = dailyList[start].humidity;
        var windSpd = dailyList[start].windSpeed * 3.6;
        var rainProb = dailyList[start].pop * 100;

        var sunRiseConvert =
            new DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
        var sunRiseTime = DateFormat.jm().format(sunRiseConvert);

        var sunSetConvert =
            new DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
        var sunSetTime = DateFormat.jm().format(sunSetConvert);

        Map<String, dynamic> dailyForecastMap = {
          "SUNRISE": "$sunRiseTime",
          "SUNSET": "$sunSetTime",
          "PRESSURE": "$pressure hPa",
          "HUMIDITY": "$humidity%",
          "WIND SPEED": widget.isMetric
              ? "${windSpd.toStringAsFixed(2)} km/h"
              : "${(windSpd / 1.7).toStringAsFixed(2)} mph",
          "CHANCE OF RAIN": "${rainProb.round()}%",
        };

        final detailName = dailyForecastMap.keys.toList();
        final detail = dailyForecastMap.values.toList();
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Colors.white54,
              ),
            ),
          ),
          child: ExpansionTile(
            title: Container(
              padding: EdgeInsets.only(
                  bottom: screenHeight * 0.01, top: screenHeight * 0.01),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        /*Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            _weather.toString(),
                            //start.toString(),
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: screenHeight * 0.023,
                            ),
                          ),
                        ),*/
                        Container(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            _weather == "Rain"
                                ? FeatherIcons.cloudDrizzle
                                : FeatherIcons.cloud,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        Container(
                          child: Text(
                            "$dailyDayDate, ",
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: screenHeight * 0.03,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            dateFinal.toString(),
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: screenHeight * 0.03,
                              //fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: Text(
                            _dailyMax.round().toString(),
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: screenHeight * 0.025,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            _dailyMin.round().toString(),
                            style: GoogleFonts.quicksand(
                              color: Colors.white54,
                              fontSize: screenHeight * 0.025,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            children: [
              GridView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                ),
                itemCount: dailyForecastMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              detailName[index].toString(),
                              style: GoogleFonts.quicksand(
                                color: Colors.white54,
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
            ],
          ),
        );
      },
    );
  }

  Widget loadingScreen() {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return hasInternet
        ? (isConnected
            ? SafeArea(
                child: Scaffold(
                  body: Container(
                    height: screenHeight,
                    width: screenWidth,
                    decoration: widget.isDayTime
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.amber,
                                Colors.amber[800],
                              ],
                            ),
                          )
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.indigo,
                                Colors.deepPurple[800],
                              ],
                            ),
                          ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Fetching $status',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: screenHeight * 0.03,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02717,
                            ),
                            child: SpinKitDoubleBounce(
                              color: Colors.white,
                              size: screenHeight * 0.06,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: Scaffold(
                  body: Container(
                    height: screenHeight,
                    width: screenWidth,
                    decoration: widget.isDayTime
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.amber,
                                Colors.amber[800],
                              ],
                            ),
                          )
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.indigo,
                                Colors.deepPurple[800],
                              ],
                            ),
                          ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                            child: Text(
                              'Failed to receive weather data',
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _onRefresh,
                            child: Container(
                              height: screenHeight * 0.075,
                              width: screenHeight * 0.075,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white70,
                                ),
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(
                                    (screenHeight * 0.075) / 2),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: screenHeight * 0.048,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        : noInternet();
  }

  Widget noInternet() {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: _onRefresh,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: screenHeight,
            width: screenWidth,
            decoration: widget.isDayTime
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.amber,
                        Colors.amber[800],
                      ],
                    ),
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.indigo,
                        Colors.deepPurple[800],
                      ],
                    ),
                  ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    child: Text(
                      'Looks like you have no internet',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: screenHeight * 0.03,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onRefresh,
                    child: Container(
                      height: screenHeight * 0.075,
                      width: screenHeight * 0.075,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white70,
                        ),
                        color: Colors.white24,
                        borderRadius:
                            BorderRadius.circular((screenHeight * 0.075) / 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.white,
                          size: screenHeight * 0.048,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bootSequence() async {
    await checkConnection();
    print("Internet? $hasInternet");
    if (hasInternet == true) {
      try {
        setState(() {
          status = "location";
        });
        await Services.getPosition().then((value) {
          setState(() {
            print('location received');
            position = value;
            lat = position.latitude;
            lon = position.longitude;

            status = "weather data";
          });
        });

        setState(() {
          status = "weather data";
        });
        print('Fetching weather data');
        await Services.getWeather(lat, lon, apiKey).then((value) {
          setState(() {
            currentWeather = value;
            status = "forecast data";
          });
          if (currentWeather.weather[0].main == 'Rain') {
            print('rain');
            setState(() {
              icon = FeatherIcons.cloudDrizzle;
            });
          } else if (currentWeather.weather[0].main == 'Clouds') {
            print('clouds');
            setState(() {
              icon = FeatherIcons.cloud;
            });
          }
        });

        setState(() {
          status = "daily forecast data";
        });
        await Services.getDailyForecastList(lat, lon, apiKey).then((value) {
          setState(() {
            dailyList = value;
            isLoading = false;
          });
        });

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print(e.toString());
        setState(() {
          isConnected = false;
        });
      } finally {
        print("Connected $isConnected");
        print("Loading $isLoading");
      }
    } else if (hasInternet == false) {
      setState(() {
        isLoading = true;
        isConnected = false;
        hasInternet = false;
      });
      print('u have no internet');
    }
    print("InternetStatus $hasInternet");
  }

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult.toString());
    if (connectivityResult == ConnectivityResult.none) {
      // Mobile is not Connected to Internet
      setState(() {
        hasInternet = false;
      });
    } else if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      setState(() {
        hasInternet = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        hasInternet = true;
      });
      // I am connected to a wifi network.
    }
  }

  void _onRefresh() async {
    setState(() {
      isLoading = true;
      isConnected = true;
      hasInternet = true;
    });
    if (hasInternet == true) {
      await bootSequence();
    } else {
      setState(() {
        isConnected = false;
      });
    }

    //print(MediaQuery.of(context).size.height.toString());
    //print(MediaQuery.of(context).size.width.toString());
    //print(MediaQuery.of(context).devicePixelRatio.toString());

    refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
      isConnected = true;
      hasInternet = false;
    });
    bootSequence();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return hasInternet
        ? (isLoading
            ? loadingScreen()
            : SafeArea(
                child: Scaffold(
                  body: Container(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.03,
                        left: screenWidth * 0.0555,
                        right: screenWidth * 0.0555),
                    width: screenWidth,
                    height: screenHeight,
                    decoration: widget.isDayTime
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.amber,
                                Colors.amber[800],
                              ],
                            ),
                          )
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.indigo,
                                Colors.deepPurple[800],
                              ],
                            ),
                          ),
                    child: Container(
                      child: SmartRefresher(
                        controller: refreshController,
                        onRefresh: _onRefresh,
                        child: ListView(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    widget.areaName,
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.02717,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 30,
                                  ),
                                  child: Text(
                                    'Next 7 days',
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.028,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            dailyForecastList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ))
        : noInternet();
  }
}
