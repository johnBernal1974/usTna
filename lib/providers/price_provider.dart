import 'package:cloud_firestore/cloud_firestore.dart';

import '../src/models/price.dart';

class PricesProvider {

  CollectionReference? _ref;

  PricesProvider() {
    _ref = FirebaseFirestore.instance.collection('Prices');
  }

  Future<Price> getAll() async {
    DocumentSnapshot document = await _ref!.doc('info').get();
    if (document.exists) {
      // Verificar si el documento existe antes de intentar convertirlo
      Price price = Price.fromJson(document.data()! as Map<String, dynamic>);
      return price;
    } else {
      // Manejar el caso en el que el documento no existe
      throw Exception("El documento 'info' no existe.");
    }
  }

}