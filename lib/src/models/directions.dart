import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataInfo {
  String? text;
  int? value;

  DataInfo({
    required this.text,
    required this.value
  });

  DataInfo.fromJsonMap(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }
}

class Direction {

  DataInfo? distance;
  DataInfo? duration;
  String? startAddress;
  String? endAddress;
  LatLng? startLocation;
  LatLng? endLocation;

  Direction({
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation
  });

  Direction.fromJsonMap(Map<String, dynamic> json) {
    distance = DataInfo.fromJsonMap(json['distance']);
    duration = DataInfo.fromJsonMap(json['duration']);
    startAddress = json['start_address'];
    endAddress = json['end_address'];
    duration = DataInfo.fromJsonMap(json['duration']);
    startLocation = LatLng(json['start_location']['lat'], json['start_location']['lng']);
    endLocation = LatLng(json['end_location']['lat'], json['end_location']['lng']);
  }

  Map<String, dynamic> toJson() => {
    'distance': distance?.text,
    'duration': duration?.text,
  };

}