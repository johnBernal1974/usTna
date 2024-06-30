
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../../../../providers/auth_provider.dart';

class ContactanosController{
  late BuildContext context;

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late StreamSubscription<DocumentSnapshot<Object?>> _clientInfoSuscription;
  Client? client;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  Future<void> init (BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    getClientInfo();

  }

  void dispose(){
    _clientInfoSuscription.cancel();
  }

  void getClientInfo(){Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser()!.uid);
    _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data() as Map<String, dynamic>);
    });
  }
}