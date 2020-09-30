import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/screens/homescreen.dart';

class Settings extends StatefulWidget {
  final bool isDayTime;
  Settings({this.isDayTime});
  @override
  _SettingsState createState() => _SettingsState();
}

double screenHeight;
double screenWidth;
bool isMetric;
bool boolValue;
int intValue;

class _SettingsState extends State<Settings> {
  int selectedIndex;
  List<String> toggle = ['\u00B0C, km/h', '\u00B0F, mph'];

  changeUnit() async {
    if (selectedIndex == 0) {
      setState(() {
        isMetric = true;
      });
    } else if (selectedIndex == 1) {
      setState(() {
        isMetric = false;
      });
    }
    print(isMetric.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMetric', isMetric);
    await prefs.setInt('selectedIndex', isMetric ? 0 : 1);
    boolValue = prefs.getBool('isMetric');
    intValue = prefs.getInt('selectedIndex');
  }

  readSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    boolValue = prefs.getBool('isMetric');
    intValue = prefs.getInt('selectedIndex');
    print(boolValue.toString());
    print(intValue.toString());
  }

  checkValues() {
    print("Initial Bool Value: $boolValue");
    if (boolValue == null) {
      setState(() {
        isMetric = true;
        selectedIndex = 0;
      });
    } else if (boolValue == true) {
      setState(() {
        isMetric = true;
        selectedIndex = 0;
      });
    } else if (boolValue == false) {
      setState(() {
        isMetric = false;
        selectedIndex = 1;
      });
    }
    print("Final Bool Value: $boolValue");
    print("IsMetric Value: $isMetric");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkValues();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 100),
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
              child: Container(
                height: screenHeight * 0.07,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Container(
                  //padding: EdgeInsets.symmetric(vertical: 50),
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.8,

                  child:
                      /*ToggleSwitch(
                    minWidth: 150,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    activeBgColors: [Colors.orange, Colors.white],
                    labels: ['Metric: \u00B0C, km/h', 'Imperial: \u00B0F, mph'],
                    onToggle: (index) {
                      setState(() {
                        isMetric = !isMetric;
                      });
                      print(isMetric.toString());
                    },
                  ),*/
                      ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: toggle.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          changeUnit();
                          print(
                            index.toString(),
                          );
                        },
                        child: Container(
                          height: screenHeight * 0.07,
                          width: screenWidth * 0.4,
                          decoration: BoxDecoration(
                            /*border: Border.all(
                              width: selectedIndex == index ? 3 : 1,
                            ),*/
                            color: widget.isDayTime
                                ? selectedIndex == index
                                    ? Colors.amber[100]
                                    : Colors.amber[800]
                                : selectedIndex == index
                                    ? Colors.deepPurple[100]
                                    : Colors.deepPurple[800],
                          ),
                          child: Center(
                            child: Text(
                              toggle[index].toString(),
                              style: GoogleFonts.quicksand(
                                fontSize: screenHeight * 0.025,
                                fontWeight: selectedIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.w200,
                                color: widget.isDayTime
                                    ? selectedIndex == index
                                        ? Colors.amber[800]
                                        : Colors.amber[50]
                                    : selectedIndex == index
                                        ? Colors.deepPurple[800]
                                        : Colors.deepPurple[50],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            /*Container(
              child: RaisedButton(
                child: Text('Print isMetric'),
                onPressed: () {
                  print(isMetric.toString());
                },
              ),
            ),
            Container(
              child: RaisedButton(
                child: Text('Read Shared Prefs'),
                onPressed: () {
                  readSharedPrefs();
                },
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
