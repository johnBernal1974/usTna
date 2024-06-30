
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../../../../providers/auth_provider.dart';

class ProfileController{
  late BuildContext context;
  late Function refresh;
  Client? client;
  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late StreamSubscription<DocumentSnapshot<Object?>> _clientInfoSuscription;

  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();

    getClientInfo();

  }

  void dispose(){
    _clientInfoSuscription.cancel();
  }

  void getClientInfo(){
    Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser()!.uid);
    _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data() as Map<String, dynamic>);
      refresh();
    });
  }

}