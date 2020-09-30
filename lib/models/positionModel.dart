import 'package:geolocator/geolocator.dart';

class GetPositionClass {
  Position position;
  bool isFinished;

  GetPositionClass({this.position, this.isFinished});

  /*Future getPosition() async {
    print('getting position');
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    isFinished = true;
    //print(position.toString());
    //return position;
  }*/
}
