
import 'dart:convert';

TravelHistory travelHistoryFromJson(String str) => TravelHistory.fromJson(json.decode(str));

String travelHistoryToJson(TravelHistory data) => json.encode(data.toJson());

class TravelHistory {
  String id;
  String idClient;
  String idDriver;
  String from;
  String to;
  String nameDriver;
  String apellidosDriver;
  String placa;
  String solicitudViaje;
  String inicioViaje;
  String finalViaje;
  double tarifa;
  double tarifaDescuento;
  double tarifaInicial;
  double calificacionAlConductor;
  double calificacionAlCliente;

  TravelHistory({
    required this.id,
    required this.idClient,
    required this.idDriver,
    required this.from,
    required this.to,
    required this.nameDriver,
    required this.apellidosDriver,
    required this.placa,
    required this.solicitudViaje,
    required this.inicioViaje,
    required this.finalViaje,
    required this.tarifa,
    required this.tarifaDescuento,
    required this.tarifaInicial,
    required this.calificacionAlConductor,
    required this.calificacionAlCliente,
  });

  factory TravelHistory.fromJson(Map<String, dynamic> json) => TravelHistory(
    id: json["id"],
    idClient: json["idClient"],
    idDriver: json["idDriver"],
    from: json["from"],
    to: json["to"],
    nameDriver: json["nameDriver"],
    apellidosDriver: json["apellidosDriver"],
    placa: json["placa"],
    solicitudViaje: json["solicitudViaje"],
    inicioViaje: json["inicioViaje"],
    finalViaje: json["finalViaje"],
    tarifa: json["tarifa"]?.toDouble(),
    tarifaDescuento: json["tarifaDescuento"]?.toDouble() ?? 0,
    tarifaInicial: json["tarifaInicial"]?.toDouble() ?? 0,
    calificacionAlConductor: json["calificacionAlConductor"]?.toDouble() ?? 0,
    calificacionAlCliente: json["calificacionAlCliente"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idClient": idClient,
    "idDriver": idDriver,
    "from": from,
    "to": to,
    "nameDriver": nameDriver,
    "apellidosDriver": apellidosDriver,
    "placa": placa,
    "solicitudViaje": solicitudViaje,
    "inicioViaje": inicioViaje,
    "finalViaje": finalViaje,
    "tarifa": tarifa,
    "tarifaDescuento": tarifaDescuento,
    "tarifaInicial": tarifaInicial,
    "calificacionAlConductor": calificacionAlConductor,
    "calificacionAlCliente": calificacionAlCliente,
  };
}