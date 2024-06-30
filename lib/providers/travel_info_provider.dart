
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tayrona_usuario/src/models/travel_info.dart';

class TravelInfoProvider {

  late CollectionReference _ref;
  
  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Stream<DocumentSnapshot> getByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void> create(TravelInfo travelInfo){
    String errorMessage;

    try{
      return _ref.doc(travelInfo.id).set(travelInfo.toJson());
    }on FirebaseFirestore catch(error){
      errorMessage = error.hashCode as String;
    }

    if(errorMessage != null){
      return Future.error(errorMessage);
    }

    return Future.value();
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<TravelInfo?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if(document.exists){
      TravelInfo? travelInfo= TravelInfo.fromJson(document.data() as Map<String, dynamic>);
      return travelInfo;
    }
    else{
      return null;
    }

  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }

}