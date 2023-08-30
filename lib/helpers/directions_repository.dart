import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/directions.dart';
import 'helpers.dart';


class DirectionsRepository {
  static const baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";
  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections(
      {required LatLng origin,
        required LatLng destination,
        required BuildContext context}) async {
    final response = await _dio.get(baseUrl, queryParameters: {
      'origin': '${origin.latitude}, ${origin.longitude}',
      'destination': '${destination.latitude}, ${destination.longitude}',
      'key': '$googleAPIKey'
    });

    if (response.statusCode == 200) {
      print("response : " + response.data.toString());
      return Directions.fromMap(response.data, context);
    }

    return null;
  }
}