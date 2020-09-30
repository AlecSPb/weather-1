import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/screens/homescreen.dart';
import 'package:weather/screens/noInternetScreen.dart';

class LoadingScreen extends StatefulWidget {
  final onRefresh;

  LoadingScreen({
    this.onRefresh,
  });
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

double screenHeight;
double screenWidth;

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return hasInternet
        ? (isConnected
            ? SafeArea(
                child: Scaffold(
                  body: Container(
                    height: screenHeight,
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
                            onTap: widget.onRefresh,
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
        : NoInternet(onRefresh: widget.onRefresh);
  }
}
