import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class GeofireProvider {
  late CollectionReference _ref;
  late GeoFlutterFire _geo;

  GeofireProvider() {
    _ref = FirebaseFirestore.instance.collection('Locations');
    _geo = GeoFlutterFire();
  }

  Stream<List<DocumentSnapshot>> getNearbyDrivers(double lat, double lng, double radius) {
    GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);
    return _geo
        .collection(
      collectionRef: _ref.where('status', isEqualTo: 'driver_available'),
    )
        .within(center: center, radius: radius, field: 'position');
  }

  Stream<List<DocumentSnapshot>> getNearbyMotorcyclers(double lat, double lng, double radius) {
    GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);
    return _geo
        .collection(
      collectionRef: _ref.where('status', isEqualTo: 'motorcycler_available'),
    )
        .within(center: center, radius: radius, field: 'position');
  }

  Stream<List<DocumentSnapshot>> getNearbyEncomiendas(double lat, double lng, double radius) {
    GeoFirePoint center = _geo.point(latitude: lat, longitude: lng);

    return _geo
        .collection(
      collectionRef: _ref.where('status', whereIn: ['motorcycler_available', 'driver_available']),
    )
        .within(center: center, radius: radius, field: 'position');
  }


  Stream<DocumentSnapshot> getLocationByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void> create(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({'status': 'driver_available', 'position': myLocation.data});
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }
}
