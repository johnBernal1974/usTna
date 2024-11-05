import 'dart:convert';

TravelInfo travelInfoFromJson(String str) => TravelInfo.fromJson(json.decode(str));

String travelInfoToJson(TravelInfo data) => json.encode(data.toJson());

class TravelInfo {
  String id;
  String status;
  String idDriver;
  String from;
  String to;
  String idTravelHistory;
  double fromLat;
  double fromLng;
  double toLat;
  double toLng;
  double tarifa;
  double tarifaDescuento;
  double tarifaInicial;
  double distancia;
  double tiempoViaje;
  String horaSolicitudViaje;
  String horaInicioViaje;
  String horaFinalizacionViaje;
  String tipoServicio;
  String apuntes;

  TravelInfo({
    required this.id,
    required this.status,
    required this.idDriver,
    required this.from, // Corregido el nombre del campo
    required this.to,
    required this.idTravelHistory,
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
    required this.tarifa,
    required this.tarifaDescuento,
    required this.tarifaInicial,
    required this.distancia, // Corregido el nombre del campo
    required this.tiempoViaje,
    required this.horaSolicitudViaje,
    required this.horaInicioViaje,
    required this.horaFinalizacionViaje,
    required this.tipoServicio,
    required this.apuntes,
  });

  factory TravelInfo.fromJson(Map<String, dynamic> json) => TravelInfo(
    id: json["id"],
    status: json["status"],
    idDriver: json["idDriver"],
    from: json["from"], // Corregido el nombre del campo
    to: json["to"],
    idTravelHistory: json["idTravelHistory"],
    fromLat: json["fromLat"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    fromLng: json["fromLng"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    toLat: json["toLat"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    toLng: json["toLng"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    tarifa: json["tarifa"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    tarifaDescuento: json["tarifaDescuento"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    tarifaInicial: json["tarifaInicial"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    distancia: json["distancia"]?.toDouble() ?? 0.0, // Manejo de valores nulos y corrección del nombre del campo
    tiempoViaje: json["tiempoViaje"]?.toDouble() ?? 0.0, // Manejo de valores nulos
    horaSolicitudViaje: json["horaSolicitudViaje"],
    horaInicioViaje: json["horaInicioViaje"],
    horaFinalizacionViaje: json["horaFinalizacionViaje"],
    tipoServicio: json["tipoServicio"],
    apuntes: json["apuntes"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "idDriver": idDriver,
    "from": from, // Corregido el nombre del campo
    "to": to,
    "idTravelHistory": idTravelHistory,
    "fromLat": fromLat,
    "fromLng": fromLng,
    "toLat": toLat,
    "toLng": toLng,
    "tarifa": tarifa,
    "tarifaDescuento": tarifaDescuento,
    "tarifaInicial": tarifaInicial,
    "distancia": distancia, // Corregido el nombre del campo
    "tiempoViaje": tiempoViaje,
    "horaSolicitudViaje": horaSolicitudViaje,
    "horaInicioViaje": horaInicioViaje,
    "horaFinalizacionViaje": horaFinalizacionViaje,
    "tipoServicio": tipoServicio,
    "apuntes": apuntes,
  };
}

