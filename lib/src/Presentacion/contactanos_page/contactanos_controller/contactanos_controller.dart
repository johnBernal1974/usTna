
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/price_provider.dart';
import '../../../models/price.dart';
import 'package:zafiro_cliente/src/models/client.dart';

class ContactanosController{
  late BuildContext context;

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late StreamSubscription<DocumentSnapshot<Object?>> _clientInfoSuscription;
  late PricesProvider _pricesProvider;
  Client? client;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String? whatsappAtencionCliente;
  String? celularAtencionCliente;

  Future<void> init (BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _pricesProvider = PricesProvider();
    getClientInfo();
    obtenerDatosPrice();

  }

  void dispose(){
    _clientInfoSuscription.cancel();
  }

  void getClientInfo(){Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser()!.uid);
    _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data() as Map<String, dynamic>);
    });
  }

  void obtenerDatosPrice() async {
    try {
      Price price = await _pricesProvider.getAll();
      // Convertir a double explícitamente si es necesario
      whatsappAtencionCliente = price.theCelularAtencionUsuarios;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo los datos: $e');
      }
    }
  }

}