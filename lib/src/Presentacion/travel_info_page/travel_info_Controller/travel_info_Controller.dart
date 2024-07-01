
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayrona_usuario/providers/auth_provider.dart';
import 'package:tayrona_usuario/providers/driver_provider.dart';
import 'package:tayrona_usuario/providers/geofire_provider.dart';
import 'package:tayrona_usuario/providers/google_provider.dart';
import 'package:tayrona_usuario/providers/price_provider.dart';
import 'package:tayrona_usuario/providers/push_notifications_provider.dart';
import 'package:tayrona_usuario/providers/travel_info_provider.dart';
import 'package:tayrona_usuario/src/Presentacion/map_client_page/View/map_client_page.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import 'package:tayrona_usuario/src/models/directions.dart';
import 'package:tayrona_usuario/src/models/driver.dart';
import 'package:tayrona_usuario/src/models/place.dart';
import 'package:tayrona_usuario/src/models/price.dart';
import 'package:tayrona_usuario/src/models/travel_info.dart';
import 'package:tayrona_usuario/utils/utilsMap.dart';
import '../../../../Helpers/Dates/DateHelpers.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/client_provider.dart';
import '../../../colors/colors.dart';
import '../../travel_map_page/View/travel_map_page.dart';

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
  String? tipoServicioSeleccionado = "Transporte";

  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  final _yourGoogleAPIKey = 'AIzaSyDgVNuJAV4Ocn2qq6FoZFVLOCOOm2kIPRE';


  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.1461765,-73.641138),
    zoom: 12.0,

  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late String from = "";
  late String to = "";
  late LatLng fromLatlng;
  late LatLng toLatlng;

  Set<Polyline> polylines ={};
  List<LatLng> points = List.from([]);

  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;

  late Direction _directions;
  String? min;
  String? km;
  double? total;
  Place? place;
  int? totalInt;
  double? radioDeBusqueda;
  String rolUsuario= "";

  int distancia = 0;
  String distanciaString='';
  int duracion =0;
  String duracionString = '';
  double tiempoEnMinutos=0;
  List<String> nearbyDrivers= [];
  List<String> nearbyMotorcyclers= [];
  late StreamSubscription<List<DocumentSnapshot>> _streamSubscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _clientInfoSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _streamStatusSuscription;



  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _googleProvider = GoogleProvider();
    _pricesProvider = PricesProvider();
    _travelInfoProvider = TravelInfoProvider();
    _driverProvider = DriverProvider();
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _geofireProvider =GeofireProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    getClientInfo();

    Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      from = arguments['from'] ?? "Desconocido";
      to = arguments['to'] ?? "Desconocido";
      fromLatlng = arguments['fromlatlng'];
      toLatlng = arguments['tolatlng'];

      print('from:*************************************************** $from');
      print('to:**************************************************** $to');
      print('fromLatlng**************************************: $fromLatlng');
      print('toLatlng******************************************: $toLatlng');

      fromMarker = await createMarkerImageFromAssets('assets/images/posicion_usuario_negra.png');
      toMarker = await createMarkerImageFromAssets('assets/images/posicion_destino.png');

      animateCameraToPosition(fromLatlng.latitude, fromLatlng.longitude);
      getgoogleMapsDirections(fromLatlng, toLatlng);
    } else {
      print('Error: Los argumentos son nulos');
    }
  }

  void guardarTipoServicio(String tipoServicio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipoServicio', tipoServicio);
    print('Tipo de servicio guardado en SharedPreferencesXXXXX: $tipoServicio');
    //obtenerTipoServicio();
  }

  void obtenerTipoServicio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tipoServicioSeleccionado = prefs.getString('tipoServicio');
    if (tipoServicioSeleccionado != null) {
      print('Tipo de servicio recuperado de SharedPreferences: $tipoServicioSeleccionado');
      // Aquí podrías asignar tipoServicio a _controller.tipoServicio si es necesario
    } else {
      print('No se encontró tipo_servicio en SharedPreferences');
      // Manejo adicional si es necesario cuando tipo_servicio no está disponible
    }
  }

  void guardarApuntesConductor(String apuntes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apuntes_al_conductor', apuntes);
    print('Apuntes del conductor guardados en SharedPreferences: $apuntes');
  }

  void clearTipoServicio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipoServicio', "Transporte");
    print('Tipo de servicio guardado en SharedPreferences luego de presionar boton cancelar: $tipoServicio');
  }

  void clearApuntesAlConductor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('apuntes_al_conductor');
  }

  void deleteTravelInfo() async {
    try {
      await _travelInfoProvider.delete(_authProvider.getUser()!.uid);
      print('Documento borrado exitosamente');
      _streamStatusSuscription.cancel();
      //clearTipoServicio();
    } catch (e) {
      print('Error al borrar el documento: $e');
    }
  }

  void getClientInfo() {
    // Verificar si el usuario está autenticado correctamente
    final user = _authProvider.getUser();
    if (user != null) {
      // Obtener el ID del usuario
      final userId = user.uid;

      // Obtener el Stream de la información del cliente
      Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(userId);

      // Escuchar los cambios en el Stream
      _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
        // Verificar si el documento existe y contiene datos
        if (document.exists) {
          // Convertir los datos del documento en un objeto Client
          client = Client.fromJson(document.data() as Map<String, dynamic>);
          //refresh(); // Actualizar la interfaz de usuario si es necesario

          print('Datos del cliente obtenidos:****************************************************************');
          print(client?.toJson()); // Imprime los datos del cliente en formato JSON
        } else {
          // Manejar el caso en que el documento no exista
          print('Error: El documento del cliente no existe.');
        }
      }, onError: (error) {
        // Manejar errores que ocurran durante la escucha del Stream
        print('Error al escuchar los cambios en la información del cliente: $error');
      });
    } else {
      // Manejar el caso en que el usuario no esté autenticado correctamente
      print('Error: Usuario no autenticado.');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
    await setPolylines();
  }

  void getgoogleMapsDirections(LatLng from, LatLng to) async{

    _directions = await _googleProvider.getGoogleMapsDirections(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );

    // Obtener solo la ciudad de la dirección de origen
    String fromCity = extractCity(_directions.startAddress) ?? 'Ciudad de Origen Desconocida';

    // Obtener solo la ciudad de la dirección de destino
    String toCity = extractCity(_directions.endAddress) ?? 'Ciudad de Destino Desconocida';

    print('Ciudad de Origen***********************: $fromCity');
    print('Ciudad de Destino**********************: $toCity');


    String formattedDuration = formatDuration(_directions.duration?.text ?? '');
    String formattedDistance = _directions.distance?.text ?? '';


    distancia = _directions.distance?.value ?? 0;
    distanciaString = _directions.distance?.text ?? '';
    duracion = _directions.duration?.value ?? 0;

    tiempoEnMinutos = duracion / 60;
    duracionString = _directions.duration?.text ?? '';


    min= formattedDuration;
    km= formattedDistance;
    calcularPrecio();
    obtenerRadiodeBusqueda();
    obtenerRolUsuario();
    refresh();
  }

  Future<void> setPolylines() async {
    points = List.from([]);
    PointLatLng pointFromLatlng = PointLatLng(fromLatlng.latitude, fromLatlng.longitude);
    PointLatLng pointToLatlng = PointLatLng(toLatlng.latitude, toLatlng.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      _yourGoogleAPIKey,
      pointFromLatlng,
      pointToLatlng,
    );

    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
      polylineId: const PolylineId('poly'),
      color: negroLetras,
      points: points,
      width: 3,
    );

    polylines.add(polyline);

    addMarker('from', fromLatlng.latitude, fromLatlng.longitude, 'Origen', '', fromMarker);
    addMarker('to', toLatlng.latitude, toLatlng.longitude, 'Destino', '', toMarker);

    LatLngBounds bounds = LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));

// Extiende los límites con los puntos de la ruta y los marcadores
    for (PointLatLng point in result.points) {
      bounds = _extendBounds(bounds, LatLng(point.latitude, point.longitude));
    }
    bounds = _extendBounds(bounds, fromLatlng);
    bounds = _extendBounds(bounds, toLatlng);

// Ajusta la cámara para que todos los elementos estén visibles
    fitBounds(bounds);
    refresh();
  }

  void calcularPrecio() async {
    try {
      Price price = await _pricesProvider.getAll();
      double? valorKilometro;
      double? valorMinuto;

      if (km != null) {
        if(rolUsuario == "basico"){
          valorKilometro = double.parse(km!.split(" ")[0].replaceAll(',', '')) * price.theValorKmRegular.toDouble();
        }else if(rolUsuario == "hotel"){
          valorKilometro = double.parse(km!.split(" ")[0].replaceAll(',', '')) * price.theValorKmHotel.toDouble();
        }else if(rolUsuario == "turismo"){
          valorKilometro = double.parse(km!.split(" ")[0].replaceAll(',', '')) * price.theValorKmTurismo.toDouble();
        }else if(rolUsuario == "empresarial"){ //// se debe colocar esto en el price model del usuario y el administrador***********************
          valorKilometro = double.parse(km!.split(" ")[0].replaceAll(',', '')) * price.theValorKmTurismo.toDouble();
        }
        int? valorKilometroInt = valorKilometro?.toInt();
        print('VALOR KILOMETRO Entero***********************$valorKilometroInt');
        print('VALOR KILOMETRO***********************$valorKilometro');
      }

      if (min != null) {
        if(rolUsuario == "basico"){
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinRegular.toDouble();
        }else if(rolUsuario == "hotel"){
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinHotel.toDouble();
        }else if(rolUsuario == "turismo"){
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinTurismo.toDouble();
        }
        else if(rolUsuario == "empresarial"){//// se debe colocar esto en el price model del usuario y el administrador***********************
          valorMinuto = double.parse(min!.split(" ")[0].replaceAll(',', '')) * price.theValorMinTurismo.toDouble();
        }

        print('VALOR MINUTO***********************$valorMinuto');
        int? valorMinutoInt = valorMinuto?.toInt();
        print('VALOR MINUTO Entero***********************$valorMinutoInt');
        print('VALOR MINUTO***********************$valorMinuto');
      }

      // Convertir explícitamente a double
      total = (valorMinuto! + valorKilometro!) * price.theDinamica.toDouble();
      total = redondearACentena(total);
      total = total?.clamp(price.theTarifaMinimaRegular.toDouble(), double.infinity);
      totalInt = total!.toInt();
      print('VALOR TOTAL***********************$total');
      print('VALOR TOTALInt***********************$totalInt');

      if (total! < price.theTarifaMinimaRegular.toDouble()) {
        total = price.theTarifaMinimaRegular.toDouble();
        totalInt = total?.toInt();
      }
      refresh();
    } catch (e) {
      print('Error al calcular el precio: $e');
    }
  }
  void obtenerRolUsuario() {
    rolUsuario = client?.the20Rol ?? "";
    print('*******ROL DEL USUARIO*****************: $rolUsuario');
  }



  void obtenerRadiodeBusqueda() async{
    try {
      Price price = await _pricesProvider.getAll();
      double? radioDeBusqueda = price.theRadioDeBusqueda;
      print("/*/*/*/*/*/*/*/radio de busqueda /*/*/*/*/*/*/*/*/*/*/ $radioDeBusqueda");
      refresh();
    } catch (e) {
      print('Error al obtener el radio de busqueda: $e');
    }
  }

  double? redondearACentena(double? valor) {
    if (valor == null) return null;

    // Redondear a la centena más cercana
    return (valor / 100).round() * 100.toDouble();
  }

  Future? animateCameraToPosition(double latitude, double longitude)  async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 15

        )));

  }
  Future<BitmapDescriptor> createMarkerImageFromAssets(String path) async {
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor=
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ){
    MarkerId id =MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),

    );

    markers[id] = marker;
  }

  LatLngBounds _extendBounds(LatLngBounds bounds, LatLng newPoint) {
    if (bounds == LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0))) {
      // Si los límites son ficticios, crea nuevos límites con el nuevo punto
      return LatLngBounds(northeast: newPoint, southwest: newPoint);
    } else {
      // Si los límites ya existen, amplía los límites manualmente
      double minLat = bounds.southwest.latitude < newPoint.latitude ? bounds.southwest.latitude : newPoint.latitude;
      double minLng = bounds.southwest.longitude < newPoint.longitude ? bounds.southwest.longitude : newPoint.longitude;
      double maxLat = bounds.northeast.latitude > newPoint.latitude ? bounds.northeast.latitude : newPoint.latitude;
      double maxLng = bounds.northeast.longitude > newPoint.longitude ? bounds.northeast.longitude : newPoint.longitude;

      return LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }
  }



  void fitBounds(LatLngBounds bounds) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  String formatDuration(String durationText) {
    // Dividir la cadena de duración en partes
    List<String> parts = durationText.split(' ');

    // Mapear las partes y modificar según sea necesario
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

    // Unir las partes formateadas en una cadena
    return formattedParts.join(' ');
  }

  String? extractCity(String? fullAddress) {
    // Si la dirección completa no es nula
    if (fullAddress != null) {
      // Dividir la dirección por comas y tomar la primera parte (nombre de la ciudad)
      List<String> addressParts = fullAddress.split(',');
      if (addressParts.isNotEmpty) {
        return addressParts[1].trim();
      }
    }

    return null; // Devolver nulo si no se puede extraer la ciudad
  }

  void seleccionarBusquedaSegunTipoServicio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tipoDeServicio = prefs.getString('tipoServicio');
    print("Tipo de servicio seleccionado: $tipoDeServicio");

    if (tipoDeServicio != null) {
      switch (tipoDeServicio) {
        case "Transporte":
          print("Buscando conductores disponibles...");
          getNearbyDrivers();
          break;
        case "Moto":
          print("Buscando motociclistas disponibles...");
          getNearbyMotorcyclers();
          break;
        case "Encomienda":
          print("Buscando servicios de encomienda...");
          // Lógica para buscar servicios de encomienda
          break;
        default:
          print("Tipo de servicio no reconocido: $tipoDeServicio");
      }
    } else {
      print("Tipo de servicio no definido en SharedPreferences");
    }
  }



  void getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyDrivers(
      fromLatlng.latitude,
      fromLatlng.longitude,
      radioDeBusqueda ?? 1,
    );

    _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isNotEmpty) {
        for (DocumentSnapshot d in documentList) {
          print('CONDUCTOR ENCONTRADO **********************${d.id}');
          nearbyDrivers.add(d.id);
        }
        getDriverInfo(nearbyDrivers[0]);
        _streamSubscription?.cancel();
      } else {
        print('No se encontraron conductores cercanos.');
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
      if (documentList.isNotEmpty) {
        for (DocumentSnapshot d in documentList) {
          print('MOTOCICLISTA ENCONTRADO **********************${d.id}');
          nearbyMotorcyclers.add(d.id);
        }
        getDriverInfo(nearbyMotorcyclers[0]);
        _streamSubscription?.cancel();
      } else {
        print('No se encontraron motociclistas cercanos.');
      }
    });
  }

  void dispose (){
    _streamSubscription?.cancel();
    _clientInfoSuscription.cancel();
    _streamStatusSuscription.cancel();
    clearTipoServicio();

  }

  void _checkDriverResponse (){
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser()!.uid);
    _streamStatusSuscription = stream.listen((DocumentSnapshot document) {
      // Verificar si el documento existe y contiene datos
      if (document.exists && document.data() != null) {
        // Realizar la conversión a Map<String, dynamic> solo si hay datos
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        TravelInfo travelInfo = TravelInfo.fromJson(data);

        if(travelInfo.idDriver != null && travelInfo.status == 'accepted'){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TravelMapPage()),
                (route) => false,
          );
        } else if(travelInfo.status == 'no_accepted'){
          Snackbar.showSnackbar(context, key, 'Tu solicitud no fue aceptada');
          Future.delayed(const Duration(milliseconds: 1500), (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MapClientPage()),
                  (route) => false,
            );
          });
        }
        // clearTipoServicio();
        // clearApuntesAlConductor();
      } else {
        // Manejar caso de documento nulo o vacío
        // Por ejemplo, puedes mostrar un mensaje de error o realizar alguna otra acción apropiada
        print('El documento no existe o está vacío');
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
        horaInicioViaje: '',
        horaSolicitudViaje: DateHelpers.getStartDate(),
        horaFinalizacionViaje: ''
    );
    await _travelInfoProvider.create(travelInfo);
    _checkDriverResponse();
  }

  Future<void> getDriverInfo(String idDriver) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tipoServicio = prefs.getString('tipoServicio');
    apuntesAlConductor = prefs.getString('apuntes_al_conductor');
    Driver? driver = await _driverProvider.getById(idDriver);
    if(driver?.token != null){
      sendNotification(driver!.token);
    }
  }

  void sendNotification(String token) {
    final user = _authProvider.getUser();
    if (user == null) {
      print('User not logged in');
      return;
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

    // Print all data to the console
    print('Sending notification with data: $data');

    _pushNotificationsProvider.sendMessage(token, data).then((response) {
      print('Notification sent successfully');
    }).catchError((error) {
      print('Failed to send notification: $error');
    });
  }
}