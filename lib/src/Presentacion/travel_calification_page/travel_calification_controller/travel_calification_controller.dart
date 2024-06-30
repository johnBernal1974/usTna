

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../providers/travel_history_provider.dart';
import '../../../models/travelHistory.dart';

class TravelCalificationController{

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String? idTravelHistory;
  double? calification;

  late TravelHistoryProvider _travelHistoryProvider;
  TravelHistory? travelHistory;


  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context)?.settings.arguments as String;
    _travelHistoryProvider = TravelHistoryProvider();
    getTravelHistory ();
    print( 'idTravel history *****************************$idTravelHistory');


  }

  void calificate() async {
    if(calification == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor calificar al conductor.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if(calification == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La calificación mínima es 1.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Map<String, dynamic> data ={
      'calificacionAlConductor': calification
    };
    await _travelHistoryProvider.update(data, idTravelHistory!);
    Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
  }

  void getTravelHistory () async {
    travelHistory = await _travelHistoryProvider.getById(idTravelHistory!);
    if (travelHistory != null) {
      print('Historial de viaje:************************** $travelHistory');
      print('Origen: ************************* ${travelHistory!.from}');
      print('Destino: ************************ ${travelHistory!.to}');
      print('tarifa: ************************ ${travelHistory!.tarifa}');
    } else {
      print('No se pudo obtener el historial de viaje.');
    }
    refresh();
  }
}

