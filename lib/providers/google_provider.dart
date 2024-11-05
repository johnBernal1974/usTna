import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../src/models/directions.dart';


class GoogleProvider {

  Future<dynamic> getGoogleMapsDirections (double fromLat, double fromLng, double toLat, double toLng) async {
    String apiKey = dotenv.env['API_KEY'] ?? '';
    Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/directions/json', {
      'key': apiKey,
      'origin': '$fromLat,$fromLng',
      'destination': '$toLat,$toLng',
      'traffic_model' : 'best_guess',
      'departure_time': DateTime.now().microsecondsSinceEpoch.toString(),
      'mode': 'driving',
      'transit_routing_preferences': 'less_driving'
    }
    );

    final response = await http.get(uri);
    final decodedData = json.decode(response.body);
    final leg = Direction.fromJsonMap(decodedData['routes'][0]['legs'][0]);
    return leg;
  }
}