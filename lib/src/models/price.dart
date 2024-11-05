// To parse this JSON data, do
//
//     final price = priceFromJson(jsonString);

import 'dart:convert';

Price priceFromJson(String str) => Price.fromJson(json.decode(str));

String priceToJson(Price data) => json.encode(data.toJson());

class Price {
  String theCorreoUsuarios;
  String theCelularAtencionUsuarios;
  String theLinkCancelarCuenta;
  String theLinkPoliticasPrivacidad;
  String theVersionUsuarioAndroid;
  String theVersionusuarioIos;
  String theMantenimientoUsuarios;
  int theDistanciaTarifaMinima;
  int theNumeroCancelacionesUsuario;
  double theRadioDeBusqueda;
  int theTarifaAeropuerto;
  int theTarifaMinimaRegular;
  int theTarifaMinimaHotel;
  int theTarifaMinimaTurismo;
  int theTiempoDeBloqueo;
  double theValorAdicionalMaps;
  double theValorIva;
  double theValorKmHotel;
  double theValorKmRegular;
  double theValorKmTurismo;
  double theValorMinHotel;
  double theValorMinRegular;
  double theValorMinTurismo;
  double theDinamica;
  String theLinkDescargaClient;
  String theLinkDescargaDriver;


  Price({

    required this.theCorreoUsuarios,
    required this.theCelularAtencionUsuarios,
    required this.theLinkCancelarCuenta,
    required this.theLinkPoliticasPrivacidad,
    required this.theVersionUsuarioAndroid,
    required this.theVersionusuarioIos,
    required this.theMantenimientoUsuarios,
    required this.theDistanciaTarifaMinima,
    required this.theNumeroCancelacionesUsuario,
    required this.theRadioDeBusqueda,
    required this.theTarifaAeropuerto,
    required this.theTarifaMinimaRegular,
    required this.theTarifaMinimaHotel,
    required this.theTarifaMinimaTurismo,
    required this.theTiempoDeBloqueo,
    required this.theValorAdicionalMaps,
    required this.theValorIva,
    required this.theValorKmHotel,
    required this.theValorKmRegular,
    required this.theValorKmTurismo,
    required this.theValorMinHotel,
    required this.theValorMinRegular,
    required this.theValorMinTurismo,
    required this.theDinamica,
    required this.theLinkDescargaClient,
    required this.theLinkDescargaDriver,


  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    theCorreoUsuarios: json["correo_usuarios"]  ?? '',
    theCelularAtencionUsuarios: json["celular_atencion_usuarios"]  ?? '',
    theLinkCancelarCuenta: json["link_cancelar_cuenta"]  ?? '',
    theLinkPoliticasPrivacidad: json["link_politicas_privacidad"]  ?? '',
    theVersionUsuarioAndroid: json["version_usuario_android"]  ?? '',
    theVersionusuarioIos: json["version_usuario_ios"]  ?? '',
    theMantenimientoUsuarios: json["mantenimiento_usuarios"]  ?? '',
    theDistanciaTarifaMinima: json["distancia_tarifa_minima"]  ?? '',
    theNumeroCancelacionesUsuario: json["numero_cancelaciones_usuario"]  ?? '',
    theRadioDeBusqueda: json["radio_de_busqueda"]?.toDouble() ?? 0.0,
    theTarifaAeropuerto: json["tarifa_aeropuerto"]  ?? '',
    theTarifaMinimaRegular: json["tarifa_minima_regular"]?? '',
    theTarifaMinimaHotel: json["tarifa_minima_hotel"]  ?? '',
    theTarifaMinimaTurismo: json["tarifa_minima_turismo"]  ?? '',
    theTiempoDeBloqueo: json["tiempo_de_bloqueo"]  ?? '',
    theValorAdicionalMaps: json["valor_adicional_maps"]?.toDouble() ?? 0.0,
    theValorIva: json["valor_Iva"]?.toDouble() ?? 0.0,
    theValorKmHotel: json["valor_km_hotel"]?.toDouble() ?? 0.0,
    theValorKmRegular: json["valor_km_regular"]?.toDouble() ?? 0.0,
    theValorKmTurismo: json["valor_km_turismo"]?.toDouble() ?? 0.0,
    theValorMinHotel: json["valor_min_hotel"]?.toDouble() ?? 0.0,
    theValorMinRegular: json["valor_min_regular"]?.toDouble() ?? 0.0,
    theValorMinTurismo: json["valor_min_turismo"]?.toDouble() ?? 0.0,
    theDinamica: json["dinamica"]?.toDouble() ?? 0.0,
    theLinkDescargaClient: json["link_descarga_client"]?? '',
    theLinkDescargaDriver: json["link_descarga_driver"]?? '',

  );

  Map<String, dynamic> toJson() => {
    "correo_usuarios": theCorreoUsuarios,
    "celular_atencion_usuarios": theCelularAtencionUsuarios,
    "link_cancelar_cuenta": theLinkCancelarCuenta,
    "link_politicas_privacidad": theLinkPoliticasPrivacidad,
    "version_usuario_android": theVersionUsuarioAndroid,
    "version_usuario_ios": theVersionusuarioIos,
    "mantenimiento_usuarios": theMantenimientoUsuarios,
    "distancia_tarifa_minima": theDistanciaTarifaMinima,
    "numero_cancelaciones_usuario": theNumeroCancelacionesUsuario,
    "radio_de_busqueda": theRadioDeBusqueda,
    "tarifa_aeropuerto": theTarifaAeropuerto,
    "tarifa_minima_regular": theTarifaMinimaRegular,
    "tarifa_minima_hotel": theTarifaMinimaHotel,
    "tarifa_minima_turismo": theTarifaMinimaTurismo,
    "tiempo_de_bloqueo": theTiempoDeBloqueo,
    "valor_adicional_maps": theValorAdicionalMaps,
    "valor_Iva": theValorIva,
    "valor_km_hotel": theValorKmHotel,
    "valor_km_regular": theValorKmRegular,
    "valor_km_turismo": theValorKmTurismo,
    "valor_min_hotel": theValorMinHotel,
    "valor_min_regular": theValorMinRegular,
    "valor_min_turismo": theValorMinTurismo,
    "dinamica": theDinamica,
    "link_descarga_client": theLinkDescargaClient,
    "link_descarga_driver": theLinkDescargaDriver,
  };
}
