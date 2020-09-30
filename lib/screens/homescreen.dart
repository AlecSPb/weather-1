import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:weather/models/forecastModel.dart';

import 'package:weather/models/weatherModel.dart';
import 'package:weather/models/dailyForecastModel.dart';
import 'package:weather/models/weatherservices.dart';
import 'package:weather/screens/dailyForecastScreen.dart';
import 'package:weather/screens/loadingScreen.dart';
import 'package:weather/screens/locationScreen.dart';
import 'package:weather/screens/noInternetScreen.dart';
import 'package:weather/screens/settingsScreen.dart';
import 'package:weather/widgets/currentWeatherDetails.dart';
import 'package:weather/widgets/forecastPanel.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//location parameters
String apiKey = '53862ec8ca1bbd0799c36df21326f30f';
double lat;
double lon;
Position position;

GetWeatherClass currentWeather; //current weather
List<ListElement> forecastList; //5day forecast
List<Daily> dailyList; // daily forecast

bool isLoading;
bool isConnected;
String status;
bool hasInternet;

//day and date variables
String dayDate;
bool isDayTime;
String dailyDayDate;

//screensizes
double screenHeight;
double screenWidth;
double listheight;

int kelvinFactor;

var icon;

PageController forecastDetailsController = new PageController();
RefreshController refreshController = RefreshController(initialRefresh: false);

class _HomeScreenState extends State<HomeScreen> {
  Services services = new Services();

  _onLoading() async {
    //await getCurrentPosition();
    refreshController.refreshCompleted();
  }

  _onRefresh() async {
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

  bootSequence() async {
    setState(() {
      isLoading = true;
    });

    await getCurrentDate();
    await checkConnection();
    if (hasInternet == true) {
      try {
        setState(() {
          status = "location";
        });
        print('waiting for location');
        await Services.getPosition().then((value) {
          setState(() {
            print('location received');
            position = value;
            lat = position.latitude;
            lon = position.longitude;

            status = "weather data";
          });
        });

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

        await Services.getForecastList(lat, lon, apiKey).then((value) {
          print('forecast');
          setState(() {
            forecastList = value;
            status = "daily forecast data";
          });
        });

        await Services.getDailyForecastList(lat, lon, apiKey).then((value) {
          setState(() {
            dailyList = value;
            isLoading = false;
          });
        });
      } on SocketException {
        print('socket exception');
        setState(() {
          isConnected = false;
        });
      } catch (e) {
        print(e.toString());
        setState(() {
          isConnected = false;
        });
      } finally {
        setState(() {
          isLoading = false;
        });
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

  checkBoolValue() async {
    if (boolValue == null) {
      setState(() {
        isMetric = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    boolValue = prefs.getBool('isMetric');
    print("IsMetric Value: $boolValue");
  }

  //functions
  getCurrentDate() {
    final now = new DateTime.now();
    dayDate = DateFormat.MMMEd().format(now);
    setState(() {
      isDayTime = now.hour > 6 && now.hour < 18 ? true : false;
    });
  }

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

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

  //initState

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBoolValue();
    setState(() {
      isLoading = true;
      isConnected = true;
      hasInternet = false;
      selectedIndex = 0;
    });
    bootSequence();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    listheight = screenHeight * 0.17;
    return hasInternet
        ? (isLoading
            ? LoadingScreen(
                onRefresh: _onRefresh,
              )
            : SmartRefresher(
                controller: refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: SafeArea(
                  child: Scaffold(
                    extendBodyBehindAppBar: true,
                    appBar: AppBar(
                      centerTitle: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      title: Text(
                        currentWeather.name,
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: screenHeight * 0.02717,
                        ),
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationsScreen(
                                  isDayTime: isDayTime,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                top: 10, right: 20, left: 20, bottom: 10),
                            child: Text(
                              '+',
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: screenHeight * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    drawer: Drawer(
                      child: ListView(
                        children: [
                          DrawerHeader(
                            child: Text('Quick Weather'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Settings(
                                    isDayTime: isDayTime,
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text('Settings'),
                              leading: Icon(Icons.settings),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: SlidingUpPanel(
                      backdropEnabled: true,
                      backdropOpacity: 0.2,
                      backdropTapClosesPanel: true,
                      maxHeight: screenHeight * 0.5,
                      minHeight: screenHeight * 0.2,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color:
                          isDayTime ? Colors.amber[50] : Colors.deepPurple[50],
                      panel: ForecastPanel(
                        forecast: forecastList,
                        isDayTime: isDayTime,
                      ),
                      body: Container(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.0555,
                          right: screenWidth * 0.0555,
                        ),
                        width: screenWidth,
                        decoration: isDayTime
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
                        child: Stack(
                          children: [
                            /*Positioned(
                              left: 80,
                              top: 0,
                              child: Container(
                                child: Transform.rotate(
                                  angle: 270,
                                  child: Icon(
                                    isDayTime
                                        ? FeatherIcons.sun
                                        : MaterialCommunityIcons
                                            .moon_waning_crescent,
                                    size: 400,
                                    color: isDayTime
                                        ? Colors.amber[200]
                                        : Colors.indigo[300],
                                  ),
                                ),
                              ),
                            ),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                        size: screenHeight * 0.0407,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        currentWeather.name,
                                        style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.02717,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        right: screenWidth * 0.0555,
                                      ),
                                      child: Text(
                                        '\u00B0 C',
                                        style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.02717,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),*/
                                Container(
                                  padding: EdgeInsets.fromLTRB(
                                    screenWidth * 0.02777,
                                    screenHeight * 0.05,
                                    screenWidth * 0.05555,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          'Today',
                                          style: GoogleFonts.quicksand(
                                            color: Colors.white,
                                            fontSize: screenHeight * 0.03,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          dayDate.toString(),
                                          style: GoogleFonts.quicksand(
                                            color: Colors.white,
                                            fontSize: screenHeight * 0.025,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.003,
                                    horizontal: screenWidth * 0.02777,
                                  ),
                                  child: Container(
                                    child: Text(
                                      isMetric
                                          ? "${(currentWeather.main.temp.round()) - (273)} \u00B0"
                                          : "${(currentWeather.main.temp * (9 / 5)).round() - (459)} \u00B0",
                                      style: GoogleFonts.quicksand(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.1087,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02777,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          right: screenWidth * 0.05555,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                                MaterialCommunityIcons
                                                    .chevron_up,
                                                color: Colors.white),
                                            Text(
                                              isMetric
                                                  ? "${(dailyList[0].temp.max - 273).round()}\u00B0"
                                                  : "${(dailyList[0].temp.max * (9 / 5)).round() - 459}\u00B0",
                                              style: GoogleFonts.quicksand(
                                                color: Colors.white,
                                                fontSize:
                                                    screenHeight * 0.02717,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Icon(
                                                MaterialCommunityIcons
                                                    .chevron_down,
                                                color: Colors.white),
                                            Text(
                                              isMetric
                                                  ? "${(dailyList[0].temp.min - 273).round()}\u00B0"
                                                  : "${(dailyList[0].temp.min * (9 / 5)).round() - 459}\u00B0",
                                              style: GoogleFonts.quicksand(
                                                color: Colors.white,
                                                fontSize:
                                                    screenHeight * 0.02717,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.02777,
                                    right: screenWidth * 0.02777,
                                    top: screenHeight * 0.008,
                                    bottom: screenHeight * 0.02,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                //padding:
                                                //EdgeInsets.symmetric(vertical: 1),
                                                child: Text(
                                                  "${currentWeather.weather[0].main}",
                                                  style: GoogleFonts.quicksand(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenHeight * 0.03,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: screenWidth * 0.02),
                                                child: Icon(
                                                  icon,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                              "${currentWeather.weather[0].description}",
                                              style: GoogleFonts.quicksand(
                                                color: Colors.white,
                                                fontSize: screenHeight * 0.025,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(right: 90),
                                                child: Text(
                                                  isMetric
                                                      ? "Feels like ${currentWeather.main.feelsLike.round() - 273}\u00B0"
                                                      : "Feels like ${(currentWeather.main.feelsLike * (9 / 5)).round() - 459}\u00B0",
                                                  style: GoogleFonts.quicksand(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenHeight * 0.023,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DailyForecast(
                                                        onRefresh: _onRefresh,
                                                        isDayTime: isDayTime,
                                                        areaName:
                                                            currentWeather.name,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.only(left: 25),
                                                  child: Container(
                                                    /*decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors.white54,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),*/
                                                    child: Text(
                                                      "Next 7 days >",
                                                      style:
                                                          GoogleFonts.quicksand(
                                                        color: Colors.white,
                                                        fontSize: screenHeight *
                                                            0.023,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  //padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: screenWidth,
                                  height: screenHeight * 0.3,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: Colors.white54, width: 1),
                                      bottom: BorderSide(
                                          color: Colors.white54, width: 1),
                                    ),
                                  ),
                                  child: CurrentWeatherDetails(
                                    currentWeather: currentWeather,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ))
        : NoInternet(
            onRefresh: _onRefresh,
          );
  }
}
