
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/travel_history_provider.dart';
import '../../../models/travelHistory.dart';

class HistorialViajesController{

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  late TravelHistoryProvider _travelHistoryProvider;
  late MyAuthProvider  _authProvider;



  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _authProvider = MyAuthProvider();
    refresh();

  }
  Future<List<TravelHistory>> getAll() async {
    return await _travelHistoryProvider.getByIdClient(_authProvider.getUser()!.uid);
  }

  void goToDetailHistory (String id) {
    Navigator.pushNamed(context, 'detail_history_page', arguments: id);
  }
}