import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:dio/dio.dart';

class DirectionsService {
  static const String _googleApiKey = 'AIzaSyDse2PDyMsk1P9u8nq8BsFvv6fWz0cLgiU';

  final PolylinePoints _polylinePoints = PolylinePoints();
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': _googleApiKey,
          'mode': 'driving',
        },
      );

      if (response.data['status'] == 'OK') {
        final route = response.data['routes'][0];
        final leg = route['legs'][0];
        
        final polyline = route['overview_polyline']['points'];
        final List<PointLatLng> result = _polylinePoints.decodePolyline(polyline);
        final List<LatLng> polylineCoordinates = result.map((p) => LatLng(p.latitude, p.longitude)).toList();

        return {
          'polyline_coordinates': polylineCoordinates,
          'distance': leg['distance']['text'],
          'duration': leg['duration']['text'],
          'bounds': _getBounds(route['bounds']),
        };
      } else {
        print('Google Directions API Error: ${response.data['status']}');
        if (response.data['error_message'] != null) {
          print('Error Message: ${response.data['error_message']}');
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  LatLngBounds _getBounds(Map<String, dynamic> bounds) {
    return LatLngBounds(
      southwest: LatLng(bounds['southwest']['lat'], bounds['southwest']['lng']),
      northeast: LatLng(bounds['northeast']['lat'], bounds['northeast']['lng']),
    );
  }
}
