import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Helpers/Dates/DateHelpers.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/geofire_provider.dart';
import '../../../../providers/google_provider.dart';
import '../../../../providers/price_provider.dart';
import '../../../../providers/push_notifications_provider.dart';
import '../../../../providers/travel_info_provider.dart';
import '../../../colors/colors.dart';
import '../../../models/directions.dart';
import '../../../models/price.dart';
import '../../../models/travel_info.dart';
import '../../travel_map_page/View/travel_map_page.dart';
import 'package:zafiro_cliente/src/models/client.dart';
import 'package:zafiro_cliente/src/models/driver.dart';
import 'package:zafiro_cliente/utils/utilsMap.dart';
import 'package:zafiro_cliente/src/models/place.dart';

class TravelInfoController{
  late BuildContext context;
  late GoogleProvider _googleProvider;
  late PricesProvider _pricesProvider;
  late TravelInfoProvider _travelInfoProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late GeofireProvider _geofireProvider;
  late PushNotificationsProvider _pushNotificationsProvider;
  late ClientProvider _clientProvider;
  Client? client;
  String? tipoServicio = "Transporte";
  String? apuntesAlConductor;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  final String _yourGoogleAPIKey = dotenv.get('API_KEY');
  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.1461765, -73.641138),
    zoom: 12.0,
  );
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late String from = "";
  late String to = "";
  late LatLng fromLatlng;
  late LatLng toLatlng;
  LatLngBounds? bounds;
  Set<Polyline> polylines = {};
  List<LatLng> points = List.from([]);
  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;
  late Direction _directions;
  Position? _position;
  String? min;
  String? km;
  double? total;
  Place? place;
  int? totalInt;
  double? radioDeBusqueda;
  String rolUsuario = "";
  int distancia = 0;
  String distanciaString = '';
  int duracion = 0;
  String duracionString = '';
  double tiempoEnMinutos = 0;
  List<String> nearbyDrivers = [];
  List<String> nearbyMotorcyclers = [];
  StreamSubscription<List<DocumentSnapshot>>? _streamSubscription;
  StreamSubscription<DocumentSnapshot<Object?>>? _clientInfoSuscription;
  StreamSubscription<DocumentSnapshot<Object?>>? _streamStatusSuscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSendingNotification = false; // Indicador para controlar el envío de notificaciones
  Set<String> notifiedDrivers = <String>{};



  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _googleProvider = GoogleProvider();
    _pricesProvider = PricesProvider();
    _travelInfoProvider = TravelInfoProvider();
    _driverProvider = DriverProvider();
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _geofireProvider = GeofireProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    await getClientInfo();
    if (arguments != null) {
      updateMap(); // Actualiza el mapa cada vez que se inicia con nuevas coordenadas
      from = arguments['from'] ?? "Desconocido";
      to = arguments['to'] ?? "Desconocido";
      fromLatlng = arguments['fromlatlng'];
      toLatlng = arguments['tolatlng'];
      animateCameraToPosition(fromLatlng.latitude, fromLatlng.longitude);
      getGoogleMapsDirections(fromLatlng, toLatlng);
      _position = await Geolocator.getCurrentPosition();
      if (_position != null) {
        initialPosition = CameraPosition(
          target: LatLng(_position!.latitude, _position!.longitude),
          zoom: 20.0,
        );
      }
    } else {
      if (kDebugMode) {
        print('Error: Los argumentos son nulos');
      }
    }
  }
  void dispose() {
    _streamSubscription?.cancel();
    _clientInfoSuscription?.cancel();
    _streamStatusSuscription?.cancel();
    clearTipoServicio();
    clearApuntesAlConductor();
    km = null;
    min = null;
    total = 0.0;
  }

  Future<void> updateMap() async {
    clearMap();
    // Crea o actualiza los marcadores
    fromMarker = await createMarkerImageFromAssets('assets/images/marker_inicio.png');
    toMarker = await createMarkerImageFromAssets('assets/images/marker_destino.png');
    addMarker('from', fromLatlng.latitude, fromLatlng.longitude, 'Origen', '', fromMarker);
    addMarker('to', toLatlng.latitude, toLatlng.longitude, 'Destino', '', toMarker);
    // Crear los límites para incluir ambos marcadores
    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(
        fromLatlng.latitude > toLatlng.latitude ? fromLatlng.latitude : toLatlng.latitude,
        fromLatlng.longitude > toLatlng.longitude ? fromLatlng.longitude : toLatlng.longitude,
      ),
      southwest: LatLng(
        fromLatlng.latitude < toLatlng.latitude ? fromLatlng.latitude : toLatlng.latitude,
        fromLatlng.longitude < toLatlng.longitude ? fromLatlng.longitude : toLatlng.longitude,
      ),
    );
    // Ajustar los límites con un margen extra
    bounds = _extendBounds(bounds, fromLatlng);
    bounds = _extendBounds(bounds, toLatlng);
    // Ajustar la cámara del mapa a los límites calculados
    if(context.mounted){
      await fitBounds(bounds, context);
    }

  }

  void addMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(title: title, snippet: content),
    );
    // Añade el marcador al mapa
    markers[id] = marker;
  }


  LatLngBounds _extendBounds(LatLngBounds? bounds, LatLng newPoint) {
    if (bounds == null) {
      return LatLngBounds(northeast: newPoint, southwest: newPoint);
    }
    double minLat = bounds.southwest.latitude < newPoint.latitude ? bounds.southwest.latitude : newPoint.latitude;
    double minLng = bounds.southwest.longitude < newPoint.longitude ? bounds.southwest.longitude : newPoint.longitude;
    double maxLat = bounds.northeast.latitude > newPoint.latitude ? bounds.northeast.latitude : newPoint.latitude;
    double maxLng = bounds.northeast.longitude > newPoint.longitude ? bounds.northeast.longitude : newPoint.longitude;
    const double margin = 0.002; // Ajustar el margen según sea necesario
    return LatLngBounds(
      southwest: LatLng(minLat - margin, minLng - margin),
      northeast: LatLng(maxLat + margin, maxLng + margin),
    );
  }


  // Método para calcular la distancia entre dos LatLng
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371e3; // En metros
    double lat1 = point1.latitude * (3.14159265359 / 180);
    double lat2 = point2.latitude * (3.14159265359 / 180);
    double deltaLat = (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    double deltaLng = (point2.longitude - point1.longitude) * (3.14159265359 / 180);
    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) *
            sin(deltaLng / 2) * sin(deltaLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distancia en metros
  }

  Future<void> fitBounds(LatLngBounds bounds, BuildContext context) async {
    GoogleMapController controller = await _mapController.future;
    double padding = MediaQuery.of(context).size.height * 0.1; // 10% del alto de la pantalla
    // Calcular el tamaño de la distancia entre los marcadores
    double distance = _calculateDistance(fromLatlng, toLatlng);
    // Si la distancia es muy pequeña, ajustar el zoom
    if (distance < 0.001) { // Puedes ajustar este valor según sea necesario
      await controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(
          (fromLatlng.latitude + toLatlng.latitude) / 2,
          (fromLatlng.longitude + toLatlng.longitude) / 2,
        ),
        15.0, // Ajusta el nivel de zoom deseado
      ));
    } else {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
    }
  }

   void clearMap() {
    polylines.clear(); // Limpia todas las polilíneas actuales
    markers.clear();   // Limpia todos los marcadores actuales
  }

  void guardarTipoServicio(String tipoServicio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipoServicio', tipoServicio);
  }

  void obtenerTipoServicio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tipoServicio = prefs.getString('tipoServicio');
    // Si no hay un tipo de servicio guardado, se establece por defecto a "Transporte"
    tipoServicio ??= "Transporte";
    apuntesAlConductor = prefs.getString('apuntes_al_conductor');
  }


  void guardarApuntesConductor(String apuntes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apuntes_al_conductor', apuntes);
    apuntesAlConductor = apuntes;
  }

  void clearTipoServicio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipoServicio', "Transporte");
  }

  void clearApuntesAlConductor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apuntes_al_conductor', "");
    // Actualizar la variable en la memoria
    apuntesAlConductor = "";
  }

  Future<void> deleteTravelInfo() async {
    try {
      // Obtener el ID del cliente actual
      String currentUserId = _authProvider.getUser()!.uid;

      // Obtener el documento del viaje usando el ID del cliente
      DocumentSnapshot travelInfoSnapshot = await _firestore.collection('TravelInfo').doc(currentUserId).get();

      // Verificar si el documento existe
      if (travelInfoSnapshot.exists) {
        // Hacer un casting del resultado a Map<String, dynamic>
        Map<String, dynamic> travelInfoData = travelInfoSnapshot.data() as Map<String, dynamic>;

        // Obtener el estado del viaje
        String status = travelInfoData['status'] ?? '';

        // Verificar si el estado es 'created'
        if (status == 'created') {
          // Borrar el documento
          await _firestore.collection('TravelInfo').doc(currentUserId).delete();
        }
      } else {
        if (kDebugMode) {
          print('El documento no existe.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al borrar el documento: $e');
      }
    }
  }


  Future<void> getClientInfo() async {
    final user = _authProvider.getUser();
    if (user != null) {
      final userId = user.uid;
      Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(userId);
      _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
        if (document.exists) {
          client = Client.fromJson(document.data() as Map<String, dynamic>);
          refresh();
        } else {
          if (kDebugMode) {
            print('Error: El documento del cliente no existe.');
          }
        }
      }, onError: (error) {
        if (kDebugMode) {
          print('Error al escuchar los cambios en la información del cliente: $error');
        }
      });
    } else {
      if (kDebugMode) {
        print('Error: Usuario no autenticado.');
      }
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle(utilsMap.mapStyle);
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    await setPolylines(); // Asegúrate de que esto no dependa de _mapController ya completado a menos que necesario
  }


  void getGoogleMapsDirections(LatLng from, LatLng to) async {
    _directions = await _googleProvider.getGoogleMapsDirections(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    // Verifica que las direcciones se hayan recibido correctamente
    String fromCity = extractCity(_directions.startAddress) ?? 'Ciudad de Origen Desconocida';
    String toCity = extractCity(_directions.endAddress) ?? 'Ciudad de Destino Desconocida';
    if (kDebugMode) {
      print('Ciudad de Origen: $fromCity');
    }
    if (kDebugMode) {
      print('Ciudad de Destino: $toCity');
    }
    // Actualiza las variables de distancia y duración
    distancia = _directions.distance?.value ?? 0;
    distanciaString = _directions.distance?.text ?? '';
    duracion = _directions.duration?.value ?? 0;
    tiempoEnMinutos = duracion / 60;
    duracionString = _directions.duration?.text ?? '';
    // Formatea y actualiza las variables para la duración y la distancia
    min = formatDuration(_directions.duration?.text ?? '');
    km = _directions.distance?.text ?? '';
    // Llama a los métodos para calcular el precio, obtener el radio de búsqueda y el rol del usuario
    calcularPrecio();
    obtenerRadiodeBusqueda();
    obtenerRolUsuario();

    setPolylines();
    }

  Future<void> setPolylines() async {
    clearMap(); // Limpia el mapa antes de establecer nuevas rutas y marcadores
    PointLatLng pointFromLatlng = PointLatLng(fromLatlng.latitude, fromLatlng.longitude);
    PointLatLng pointToLatlng = PointLatLng(toLatlng.latitude, toLatlng.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      _yourGoogleAPIKey,
      pointFromLatlng,
      pointToLatlng,
    );
    if (result.points.isNotEmpty) {
      points.clear();
      for (PointLatLng point in result.points) {
        points.add(LatLng(point.latitude, point.longitude));
      }
      Polyline polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: negro,
        points: points,
        width: 5,
      );
      polylines.add(polyline);
      // Añadir los marcadores después de configurar la ruta
      addMarker('from', fromLatlng.latitude, fromLatlng.longitude, 'Origen', '', fromMarker);
      addMarker('to', toLatlng.latitude, toLatlng.longitude, 'Destino', '', toMarker);
      refresh(); // Actualiza el mapa para mostrar las nuevas polilíneas y marcadores
    } else {
      if (kDebugMode) {
        print("No se encontraron puntos de ruta entre los puntos especificados.");
      }
    }
  }


  void calcularPrecio() async {
    try {
      Price price = await _pricesProvider.getAll();
      double? valorKilometro;
      double? valorMinuto;

      if (km != null) {
        double distanciaKm = double.parse(km!.split(" ")[0].replaceAll(',', ''));

        if (rolUsuario == "basico") {
          valorKilometro = distanciaKm * price.theValorKmRegular.toDouble();
        } else if (rolUsuario == "hotel") {
          valorKilometro = distanciaKm * price.theValorKmHotel.toDouble();
        } else if (rolUsuario == "turismo") {
          valorKilometro = distanciaKm * price.theValorKmTurismo.toDouble();
        } else if (rolUsuario == "empresarial") {
          valorKilometro = distanciaKm * price.theValorKmTurismo.toDouble();
        }

        // Si la distancia es superior a 20 km, aumentamos el precio en un 20%
        // Aplicar incrementos según la distancia
        // Aplicar incrementos según la distancia
        if (distanciaKm > 100) {
          valorKilometro = valorKilometro! * 2.00;  // Incremento del 100%
        } else if (distanciaKm > 80) {
          valorKilometro = valorKilometro! * 1.80;  // Incremento del 80%
        } else if (distanciaKm > 50) {
          valorKilometro = valorKilometro! * 1.50;  // Incremento del 50%
        } else if (distanciaKm > 40) {
          valorKilometro = valorKilometro! * 1.40;  // Incremento del 40%
        } else if (distanciaKm > 30) {
          valorKilometro = valorKilometro! * 1.30;  // Incremento del 30%
        } else if (distanciaKm > 20) {
          valorKilometro = valorKilometro! * 1.20;  // Incremento del 20%
        }


      }

      if (min != null) {
        if (rolUsuario == "basico") {
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinRegular.toDouble();
        } else if (rolUsuario == "hotel") {
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinHotel.toDouble();
        } else if (rolUsuario == "turismo") {
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinTurismo.toDouble();
        } else if (rolUsuario == "empresarial") {
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinTurismo.toDouble();
        }
      }

      // Calculamos el total
      total = (valorMinuto! + valorKilometro!) * price.theDinamica.toDouble();

      // Redondeamos a la centena más cercana
      total = redondearACentena(total);

      // Dependiendo del rol, obtenemos la tarifa mínima correspondiente
      double tarifaMinimaRol;
      if (rolUsuario == "basico") {
        tarifaMinimaRol = price.theTarifaMinimaRegular.toDouble();
      } else if (rolUsuario == "hotel") {
        tarifaMinimaRol = price.theTarifaMinimaHotel.toDouble();
      } else if (rolUsuario == "turismo") {
        tarifaMinimaRol = price.theTarifaMinimaTurismo.toDouble();
      } else {
        tarifaMinimaRol = price.theTarifaMinimaRegular.toDouble(); // Valor por defecto
      }

      // Aseguramos que el total no sea menor a la tarifa mínima del rol
      total = total?.clamp(tarifaMinimaRol, double.infinity);

      // Convertimos el total a un entero
      totalInt = total!.toInt();

      // Si el total sigue siendo menor a la tarifa mínima, lo ajustamos
      if (total! < tarifaMinimaRol) {
        total = tarifaMinimaRol;
        totalInt = total?.toInt();
      }

      // Llamamos a la función refresh para actualizar la interfaz
      refresh();

    } catch (e) {
      if (kDebugMode) {
        print('Error al calcular el precio: $e');
      }
    }
  }



  void obtenerRolUsuario() {
    rolUsuario = client?.the20Rol ?? "";
  }

  void obtenerRadiodeBusqueda() async {
    try {
      Price price = await _pricesProvider.getAll();
      radioDeBusqueda = price.theRadioDeBusqueda;
      if (kDebugMode) {
        print("Radio de busqueda: $radioDeBusqueda");
      }
      refresh();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener el radio de busqueda: $e');
      }
    }
  }

  double? redondearACentena(double? valor) {
    if (valor == null) return null;
    return (valor / 100).ceil() * 100.toDouble();
  }

  Future<void> animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 15,
      ),
    ));
  }

  Future<BitmapDescriptor> createMarkerImageFromAssets(String path) async {
    try {
      ImageConfiguration configuration = const ImageConfiguration();
      BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
      return bitmapDescriptor;
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar la imagen del marcador: $e');
      }
      return BitmapDescriptor.defaultMarker;
    }
  }

  String formatDuration(String durationText) {
    List<String> parts = durationText.split(' ');
    List<String> formattedParts = parts.map((part) {
      switch (part) {
        case 'hours':
          return 'h';
        case 'hour':
          return 'hs';
        case 'mins':
          return 'mins';
        case 'min':
          return 'min';
        default:
          return part;
      }
    }).toList();
    return formattedParts.join(' ');
  }

  String? extractCity(String? fullAddress) {
    if (fullAddress != null) {
      List<String> addressParts = fullAddress.split(',');
      if (addressParts.isNotEmpty) {
        return addressParts[1].trim();
      }
    }
    return null;
  }

  void getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyDrivers(
      fromLatlng.latitude,
      fromLatlng.longitude,
      radioDeBusqueda ?? 1,
    );

    _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      _streamSubscription?.cancel();  // Cancela la suscripción después de recibir los datos
      if (documentList.isNotEmpty) {
        nearbyDrivers = documentList.map((d) => d.id).toList(); // Aquí defines 'nearbyDrivers'
        if (kDebugMode) {
          print('Se encontraron ${nearbyDrivers.length} conductores cercanos.');
        }
        _attemptToSendNotification(nearbyDrivers, 0); // Cambiado de 'driverIds' a 'nearbyDrivers'
      } else {
        if (kDebugMode) {
          print('No se encontraron conductores cercanos.');
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Error al escuchar el stream de conductores cercanos: $error');
      }
    });
  }

  void getNearbyMotorcyclers() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyMotorcyclers(
      fromLatlng.latitude,
      fromLatlng.longitude,
      radioDeBusqueda ?? 1,
    );

    _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      _streamSubscription?.cancel(); // Cancela la suscripción después de recibir los datos

      if (documentList.isNotEmpty) {
        nearbyMotorcyclers = documentList.map((d) => d.id).toList(); // Define 'nearbyMotorcyclers'
        if (kDebugMode) {
          print('Se encontraron ${nearbyMotorcyclers.length} motociclistas cercanos.');
        }
        _attemptToSendNotification(nearbyMotorcyclers, 0); // Llama al método para enviar notificación
      } else {
        if (kDebugMode) {
          print('No se encontraron motociclistas cercanos.');
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Error al escuchar el stream de motociclistas cercanos: $error');
      }
    });
  }

  void getNearbyEncomiendas() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyEncomiendas(
      fromLatlng.latitude,
      fromLatlng.longitude,
      radioDeBusqueda ?? 1,
    );

    _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      _streamSubscription?.cancel(); // Cancela la suscripción después de recibir los datos

      if (documentList.isNotEmpty) {
        // Aquí diferenciamos entre motociclistas y conductores
        List<String> nearbyDrivers = [];
        List<String> nearbyMotorcyclers = [];

        for (var doc in documentList) {
          if (doc['status'] == 'driver_available') {
            nearbyDrivers.add(doc.id); // Si es conductor, lo agregamos a la lista de conductores
          } else if (doc['status'] == 'motorcycler_available') {
            nearbyMotorcyclers.add(doc.id); // Si es motociclista, lo agregamos a la lista de motociclistas
          }
        }

        if (kDebugMode) {
          print('Se encontraron ${nearbyDrivers.length} conductores y ${nearbyMotorcyclers.length} motociclistas cercanos.');
        }

        // Llama al método para enviar notificaciones a los conductores y motociclistas cercanos
        _attemptToSendNotification(nearbyDrivers, 0); // Notificación a conductores
        _attemptToSendNotification(nearbyMotorcyclers, 0); // Notificación a motociclistas

      } else {
        if (kDebugMode) {
          print('No se encontraron conductores ni motociclistas cercanos.');
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Error al escuchar el stream de conductores y motociclistas cercanos: $error');
      }
    });
  }



  void _attemptToSendNotification(List<String> driverIds, int index) {
    if (index >= driverIds.length) {
      if (kDebugMode) {
        print('No hay más conductores disponibles. Proceso completado.');
      }
      notifiedDrivers.clear();  // Limpiamos el conjunto para futuras búsquedas.
      return;
    }

    String driverId = driverIds[index];
    if (notifiedDrivers.contains(driverId)) {
      _attemptToSendNotification(driverIds, index + 1);
      return;
    }

    notifiedDrivers.add(driverId);  // Añadimos el conductor al conjunto de notificados.
    if (kDebugMode) {
      print("Enviando notificación al conductor $driverId");
    }

    getDriverInfo(driverId).then((_) async {
      Driver? driver = await _driverProvider.getById(driverId);
      if (driver != null) {
        if (kDebugMode) {
          print('ID del conductor: ${driver.id}');
        }
        if (kDebugMode) {
          print('Token del conductor: ${driver.token}');
        }
      } else {
        if (kDebugMode) {
          print('El conductor no fue encontrado.');
        }
      }

      // Mover la verificación de `notifiedDrivers` al inicio del bloque condicional
      if (driver?.token != null) {
        bool accepted = await sendNotification(driver!.token);
        if (accepted) {
          if (kDebugMode) {
            print('El conductor $driverId aceptó el servicio.');
          }
        } else {
          if (kDebugMode) {
            print('El conductor $driverId no aceptó el servicio, pasando al siguiente...');
          }
        }
      } else {
        if (kDebugMode) {
          print('No se pudo obtener el token del conductor $driverId, pasando al siguiente...');
        }
      }

      // Agregar al conductor después de verificar el token y enviar la notificación
      notifiedDrivers.add(driverId);
      _attemptToSendNotification(driverIds, index + 1);
    }).catchError((error) {
      if (kDebugMode) {
        print('Error al obtener información del conductor $driverId: $error');
      }
      _attemptToSendNotification(driverIds, index + 1);
    });
  }



  void _checkDriverResponse() {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser()!.uid);
    _streamStatusSuscription = stream.listen((DocumentSnapshot document) {
      if (document.exists && document.data() != null) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        TravelInfo travelInfo = TravelInfo.fromJson(data);

        if (travelInfo.status == 'accepted') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TravelMapPage()),
                (route) => false,
          );
        }
      } else {
        if (kDebugMode) {
          print('El documento no existe o está vacío');
        }
      }
    });
  }


  void createTravelInfo() async {
    TravelInfo travelInfo = TravelInfo(
        id: _authProvider.getUser()!.uid,
        status: 'created',
        idDriver: "",
        from: from,
        to: to,
        idTravelHistory: "",
        fromLat: fromLatlng.latitude,
        fromLng: fromLatlng.longitude,
        toLat: toLatlng.latitude,
        toLng: toLatlng.longitude,
        tarifa: total!,
        tarifaDescuento: 0,
        tarifaInicial: total!,
        distancia: distancia.toDouble(),
        tiempoViaje: tiempoEnMinutos,
        horaInicioViaje: null,
        horaSolicitudViaje: Timestamp.now(),
        horaFinalizacionViaje: null,
        tipoServicio: tipoServicio ?? '',
        apuntes: apuntesAlConductor ?? ''
    );
    await _travelInfoProvider.create(travelInfo);
    _checkDriverResponse();
  }

  Future<void> getDriverInfo(String idDriver) async {
  }

  Future<bool> sendNotification(String token) async {
    final user = _authProvider.getUser();
    if (user == null) {
      return false;
    }

    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'idClient': user.uid,
      'origin': from,
      'originLat': fromLatlng.latitude.toString(),
      'originLng': fromLatlng.longitude.toString(),
      'destination': to,
      'destinationLat': toLatlng.latitude.toString(),
      'destinationLng': toLatlng.longitude.toString(),
      'tarifa': totalInt.toString(),
      'tipo_servicio': tipoServicio,
      'apuntes_usuario': apuntesAlConductor,
    };

    try {
      await _pushNotificationsProvider.sendMessage(token, data);
      if (kDebugMode) {
        print('Notification sent successfully');
      }
      await Future.delayed(const Duration(seconds: 20)); // Simular tiempo de espera
      return false;
    } catch (error) {
      if (kDebugMode) {
        print('Failed to send notification: $error');
      }
      return false;
    }
  }

}
