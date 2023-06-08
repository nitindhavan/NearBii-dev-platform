import 'dart:math' as Math;

double degreesToRadians(double degrees) {
  return degrees * (Math.pi / 180);
}

double radiansToDegrees(double radians) {
  return radians * (180 / Math.pi);
}

// Calculate the maximum and minimum latitude and longitude within a radius of N kilometers from a specific location
MinMaxModel calculateBounds(double latitude, double longitude, double radiusInKm) {
  const double earthRadius = 6371; // in kilometers

  double latRadian = degreesToRadians(latitude);
  double lonRadian = degreesToRadians(longitude);

  double angularDistance = radiusInKm / earthRadius;

  double minLat = latRadian - angularDistance;
  double maxLat = latRadian + angularDistance;

  double deltaLon = Math.asin(Math.sin(angularDistance) / Math.cos(latRadian));
  double minLon = lonRadian - deltaLon;
  double maxLon = lonRadian + deltaLon;

  double minLatitude = radiansToDegrees(minLat);
  double maxLatitude = radiansToDegrees(maxLat);
  double minLongitude = radiansToDegrees(minLon);
  double maxLongitude = radiansToDegrees(maxLon);


  return MinMaxModel(minLatitude, maxLatitude, minLongitude, maxLongitude);
  print('Minimum Latitude: $minLatitude');
  print('Maximum Latitude: $maxLatitude');
  print('Minimum Longitude: $minLongitude');
  print('Maximum Longitude: $maxLongitude');
}

class MinMaxModel{
  double minLat;
  double maxLat;
  double minLong;
  double maxLong;
  MinMaxModel(this.minLat,this.maxLat,this.minLong,this.maxLong);
}
