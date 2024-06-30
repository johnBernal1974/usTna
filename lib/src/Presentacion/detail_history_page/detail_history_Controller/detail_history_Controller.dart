
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/providers/travel_history_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import 'package:tayrona_usuario/src/models/driver.dart';
import 'package:tayrona_usuario/src/models/travelHistory.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';

class DetailHistoryController{
  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late Function refresh;
  late TravelHistoryProvider _travelHistoryProvider;
  late DriverProvider _driverProvider;
  String? idTravelHistory;
  TravelHistory? travelHistory;
  Driver? driver;

  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _driverProvider = DriverProvider();

    idTravelHistory = ModalRoute.of(context)?.settings.arguments as String;

    print('idTravelHistory******************* en el detal******$idTravelHistory');

    getTravelHistoryInfo ();

  }
  void getTravelHistoryInfo () async {
    TravelHistory? history = await _travelHistoryProvider.getById(idTravelHistory!);
    if (history != null) {
      travelHistory = history;
      getDriverInfo(travelHistory?.idDriver ?? '');
    }
  }

  void getDriverInfo(String idDriver) async {
    driver = (await _driverProvider.getById(idDriver))!;
    refresh();
  }

}