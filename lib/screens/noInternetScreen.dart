import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:weather/screens/homescreen.dart';

class NoInternet extends StatefulWidget {
  final onRefresh;

  NoInternet({
    this.onRefresh,
  });
  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SmartRefresher(
      controller: refreshController,
      onRefresh: widget.onRefresh,
      child: SafeArea(
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
                    onTap: widget.onRefresh,
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
      ),
    );
  }
}
