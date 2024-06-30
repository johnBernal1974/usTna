
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart' as location;
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/geofire_provider.dart';
import '../../../../providers/travel_info_provider.dart';
import '../../../colors/colors.dart';
import '../../../models/driver.dart';
import '../../../models/travel_info.dart';

import 'package:tayrona_usuario/utils/utilsMap.dart';

import '../../commons_widgets/bottom_sheets/bottom_sheet_driver_info.dart';

class TravelMapController{
  late BuildContext context;
  late Function refresh;
  bool isMoto = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  final _yourGoogleAPIKey = 'AIzaSyDgVNuJAV4Ocn2qq6FoZFVLOCOOm2kIPRE';
  late AudioPlayer _player;
  bool _soundBienvenidaReproducido = false;
  bool _soundConductorLlegadaReproducido = false;
  bool _soundConductorHaCanceladoReproducido = false;

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.8470616, -74.0743461),
    zoom: 12.0,

  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late BitmapDescriptor markerDriver;
  late BitmapDescriptor markerMotorcycler;
  late GeofireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;
  bool isConected = true;
  late StreamSubscription<DocumentSnapshot<Object?>> _statusSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _streamLocationController;
  late StreamSubscription<DocumentSnapshot<Object?>> _streamTravelController;
  late StreamSubscription<DocumentSnapshot<Object?>> _streamStatusController;
  late TravelInfoProvider _travelInfoProvider;
  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;
  Driver? driver;
  Client? client;
  LatLng? _driverLatlng;
  TravelInfo? travelInfo;
  bool isRouteready = false;
  String currentStatus = '';
  bool isPickUpTravel = false;
  bool isStartTravel = false;
  bool isFinishtTravel = false;
  bool soundIsaceptado = false;
  Set<Polyline> polylines ={};
  List<LatLng> points = List.from([]);
  Timer? _timer;
  int seconds = 0;
  double mts = 0;
  double kms = 0;

  final StreamController<double> timeRemainingController = StreamController<double>.broadcast();
  //
  // double _distanceTraveled = 0; // Para mantener un seguimiento de la distancia recorrida
  // double _estimatedSpeed = 30; // Velocidad estimada en km/h
  // double _timeRemaining = 0; // Tiempo restante estimado

  String? status = '';




  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _travelInfoProvider = TravelInfoProvider();
    markerDriver = await createMarkerImageFromAssets('assets/images/vehiculo_disponible7.png');
    markerMotorcycler = await createMarkerImageFromAssets('assets/images/marcador_motos2.png');
    fromMarker = await createMarkerImageFromAssets('assets/images/posicion_usuario_negra.png');
    toMarker = await createMarkerImageFromAssets('assets/images/posicion_destino.png');
    checkGPS();
    _getTravelInfo();
    obtenerStatus();
    _actualizarIsTravelingTrue();

  }
  //
  // // Método para calcular la distancia entre dos puntos en metros
  // double calculateDistance(LatLng point1, LatLng point2) {
  //   const int earthRadius = 6371000; // Radio de la Tierra en metros
  //
  //   // Convertir coordenadas de grados a radianes
  //   double lat1Radians = degreesToRadians(_driverLatlng!.latitude);
  //   double lon1Radians = degreesToRadians(_driverLatlng!.longitude);
  //   double lat2Radians = degreesToRadians(travelInfo!.fromLat);
  //   double lon2Radians = degreesToRadians(travelInfo!.fromLng);
  //
  //   // Calcular diferencias de latitud y longitud
  //   double latDiff = lat2Radians - lat1Radians;
  //   double lonDiff = lon2Radians - lon1Radians;
  //
  //   // Calcular la distancia utilizando la fórmula de Haversine
  //   double a = pow(sin(latDiff / 2), 2) +
  //       cos(lat1Radians) * cos(lat2Radians) * pow(sin(lonDiff / 2), 2);
  //   double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  //   double distance = earthRadius * c;
  //
  //   return distance; // Devuelve la distancia en metros
  // }
  //
  // // Convertir grados a radianes
  // double degreesToRadians(double degrees) {
  //   return degrees * pi / 180;
  // }
  //
  // // Método para calcular el tiempo restante basado en la distancia recorrida y la velocidad estimada
  // void calculateRemainingTime(LatLng driverLocation) {
  //   double distanceInMeters = calculateDistance(
  //       LatLng(travelInfo!.fromLat, travelInfo!.fromLng), driverLocation);
  //   _distanceTraveled += distanceInMeters; // Actualiza la distancia recorrida
  //   _timeRemaining = (_distanceTraveled / 1000) / _estimatedSpeed; // Calcula el tiempo restante en horas
  //   updateTimeRemaining(_timeRemaining); // Actualiza el tiempo restante en la interfaz de usuario
  // }
  //
  // void updateTimeRemaining(double timeRemaining) {
  //   print('Tiempo restante actualizado: $timeRemaining');
  //   timeRemainingController.add(timeRemaining);
  // }
  //
  // // Método que se llama cuando se actualiza la ubicación del conductor
  // void onDriverLocationUpdated(LatLng driverLocation) {
  //   calculateRemainingTime(driverLocation); // Calcula el tiempo restante cuando se recibe una nueva ubicación del conductor
  // }


  void _getTravelInfo() async {
    // Obtener la información del viaje del proveedor de información de viaje
    travelInfo = await _travelInfoProvider.getById(_authProvider.getUser()!.uid);

    // Configurar la posición inicial en la ubicación de destino (to)
    animateCameraToPosition(travelInfo!.fromLat, travelInfo!.fromLng);

    // Obtener información del conductor y ubicación del conductor
    getDriverInfo(travelInfo!.idDriver);
    getClientInfo();
    getDriverLocation(travelInfo!.idDriver);

  }

  void obtenerStatus() async {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser()!.uid);
    _streamStatusController = stream.listen((DocumentSnapshot document) {
      if (document.data() == null) return;
      travelInfo = TravelInfo.fromJson(document.data() as Map<String, dynamic>);
      if (travelInfo == null) return;
      status= travelInfo!.status;

    });
  }

  void checkTravelStatus() async {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser()!.uid);
    _streamTravelController = stream.listen((DocumentSnapshot document) {
      if (document.data() == null) return;

      travelInfo = TravelInfo.fromJson(document.data() as Map<String, dynamic>);

      if (travelInfo == null) return;

      switch (travelInfo!.status) {
        case 'accepted':
          currentStatus = 'Viaje aceptado';
          if (!soundIsaceptado) {
            soundIsaceptado = true;
            soundViajeAceptado('assets/audio/aceptado.mp3');
          }
          pickupTravel();
          break;
        case 'driver_on_the_way':
          currentStatus = 'Conductor en camino';
          break;
        case 'driver_is_waiting':
          currentStatus = 'El Conductor ha llegado';
          _soundConductorHaLlegado('assets/audio/ringtone_tayrona_ha_llegado.mp3');
          break;
        case 'started':
          currentStatus = 'Viaje iniciado';
          verificarGenero();
          startTravel();
          break;
        case 'cancelByDriverAfterAccepted':
          if (context != null) {
            Navigator.pushReplacementNamed(context, 'map_client');
            _soundConductorHaCancelado('assets/audio/conductor_cancelo_servicio.mp3');
            _actualizarIsTravelingFalse();
            if (key != null) {
              Snackbar.showSnackbar(context, key, 'El conductor canceló el servicio');
            }
          }
          break;
        case 'cancelTimeIsOver':
          if (context != null) {
            Navigator.pushReplacementNamed(context, 'map_client');
            _soundConductorHaCancelado('assets/audio/conductor_cancelo_servicio.mp3');
            _actualizarIsTravelingFalse();
            if (key != null) {
              Snackbar.showSnackbar(context, key, 'El conductor canceló el servicio por tiempo de espera cumplido');
            }
          }
          break;
        case 'finished':
          currentStatus = 'Viaje finalizado';
          finishTravel();
          break;
        default:
          break;
      }

      refresh();
    });
  }

  void cancelTravelByClient() {
    Map<String, dynamic> data = {
      'status': 'cancelTravelByClient',
    };
    _travelInfoProvider.update(data, _authProvider.getUser()!.uid);
    _actualizarIsTravelingFalse ();
    _deleteTravelInfo();
    actualizarContadorCancelaciones();

    // Navegación y cierre del AlertDialog
    Navigator.pushNamedAndRemoveUntil(
      context,
      'map_client', // La ruta de la pantalla a la que quieres navegar
          (route) => false, // La condición para eliminar rutas anteriores (en este caso, siempre false para borrar todas las rutas)
    ).then((_) {
      // Asegura cerrar el diálogo después de que se complete la navegación
      Navigator.pop(context);
    });
  }

  void _deleteTravelInfo() async {
    try {
      await _travelInfoProvider.delete(_authProvider.getUser()!.uid);
      print('Documento borrado exitosamente');
    } catch (e) {
      print('Error al borrar el documento: $e');
    }
  }

  void actualizarContadorDeViajes () async {
    int? numeroDeViajes = client?.the19Viajes;
    int nuevoContador = numeroDeViajes! + 1;
    Map<String, dynamic> data = {
      '19_Viajes': nuevoContador};
    await _clientProvider.update(data, _authProvider.getUser()!.uid);
    refresh();

  }

  void actualizarContadorCancelaciones () async {
    int? numeroCancelaciones = client?.the22Cancelaciones;
    int nuevoContadorCancelaciones = numeroCancelaciones! + 1;

    Map<String, dynamic> data = {
      '22_cancelaciones': nuevoContadorCancelaciones};
    await _clientProvider.update(data, _authProvider.getUser()!.uid);
    refresh();

  }


  void verificarGenero() {
    // Solo reproducir el sonido si no se ha reproducido antes
    if (!_soundBienvenidaReproducido) {
      String genero = client?.the09Genero ?? '';
      if (genero == 'Masculino' || genero == '' || genero.isEmpty) {
        _soundBienvenidoABordo('assets/audio/bienvenido_a_bordo.mp3');
      } else {
        _soundBienvenidaABordo('assets/audio/bienvenida_a_bordo.mp3');
      }
      _soundBienvenidaReproducido = true; // Actualiza la bandera para indicar que el sonido ya se ha reproducido
    }
  }

  void centerPosition() {
    if (_driverLatlng != null) {
      animateCameraToPosition(_driverLatlng!.latitude, _driverLatlng!.longitude);
    }
  }

  void getDriverLocation(String idDriver) {
    Stream<DocumentSnapshot> stream = _geofireProvider.getLocationByIdStream(idDriver);
    _streamLocationController = stream.listen((DocumentSnapshot document) {
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('position')) {
        GeoPoint? geoPoint = data['position']['geopoint'];
        if (geoPoint != null) {
          double latitude = geoPoint.latitude;
          double longitude = geoPoint.longitude;
          print('Driver Location  ***********//////////////************************** - Latitude: $latitude, Longitude: $longitude');
          _driverLatlng = LatLng(latitude, longitude);
          addMarker('driver', _driverLatlng!.latitude, _driverLatlng!.longitude,'Tu conductor', '', markerDriver);
          print('MARKERS**************************$markers'); // Verificar el estado de los marcadores después de agregar el marcador del conductor
          refresh();
          if (!isRouteready) {
            isRouteready = true;
            checkTravelStatus ();
            //updateTimeRemaining(_timeRemaining);
          }
        }
      }
    });
  }
  void pickupTravel () {
    if(!isPickUpTravel){
      isPickUpTravel = true;
      LatLng from = LatLng(_driverLatlng!.latitude, _driverLatlng!.longitude);
      LatLng to = LatLng(travelInfo!.fromLat, travelInfo!.fromLng);
      addMarker('from', to.latitude, to.longitude, 'Recoger aquí', '', fromMarker);
      setPolylines(from, to);
    }

  }

  void startTravel() {
    if(!isStartTravel){
      isStartTravel= true;
      polylines = {};
      points = List.from([]);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addMarker('to', travelInfo!.toLat, travelInfo!.toLng, 'Destino', '', toMarker);
      LatLng from = LatLng(_driverLatlng!.latitude, _driverLatlng!.longitude);
      LatLng to = LatLng(travelInfo!.toLat, travelInfo!.toLng);

      setPolylines(from, to);
      refresh();
    }

  }

  void finishTravel(){
    if(!isFinishtTravel){
      isFinishtTravel = true;
      soundHasLlegadoATuDestino('assets/audio/has_llegado_sound.mp3');
      String idtravelHistory = travelInfo?.idTravelHistory ?? '';
      print('idtravelHistory************************************************$idtravelHistory');
      _actualizarIsTravelingFalse ();
      actualizarContadorDeViajes();
      Navigator.pushNamedAndRemoveUntil(context, 'travel_calification_page', (route) => false, arguments: travelInfo!.idTravelHistory);
    }
  }

  void getDriverInfo(String id) async {
   driver = await _driverProvider.getById(id);
   refresh();
  }

  void getClientInfo() async {
    client = await _clientProvider.getById(_authProvider.getUser()!.uid);
  }

  void _actualizarIsTravelingTrue () async {
    Map<String, dynamic> data = {
      '00_is_traveling': true};
    await _clientProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void _actualizarIsTravelingFalse () async {
    Map<String, dynamic> data = {
      '00_is_traveling': false};
    await _clientProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {
    points = List.from([]);
    PointLatLng pointFromLatlng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatlng = PointLatLng(to.latitude, to.longitude);

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
      color: azulOscuro,
      points: points,
      width: 3,
    );

    polylines.add(polyline);
    refresh();
  }

  void dispose(){
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
    _streamLocationController.cancel();
    _streamTravelController.cancel();
    _streamStatusController.cancel();

  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
    _getTravelInfo();
  }

  void checkGPS() async{
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(islocationEnabled){
      print('GPS activado');
    }
    else{
      print('GPS desactivado');
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        print(' el usuario activo el GPS');
      }
    }
  }


  void goToCompartirAplicacion(){
    Navigator.pushNamed(context, "compartir_aplicacion");
  }

  void goToProfile(){
    Navigator.pushNamed(context, "profile");
  }

  void goToEliminarCuenta(){
    Navigator.pushNamed(context, "eliminar_cuenta");
  }

  Future? animateCameraToPosition(double latitude, double longitude)  async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 15.1

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
      BitmapDescriptor iconMarker,

      ) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),

    );

    markers[id] = marker;
  }

  void _soundConductorHaLlegado(String audioPath) async {
    // Solo reproducir el sonido si no se ha reproducido antes
    if (!_soundConductorLlegadaReproducido) {
      print('Intentando reproducir audio: ********$audioPath');
      _player = AudioPlayer();
      await _player.setAsset(audioPath); // Utiliza la ruta completa al archivo de audio
      await _player.play();
      print('Audio reproducido exitosamente****************************');
      _soundConductorLlegadaReproducido = true; // Actualiza la bandera para indicar que el sonido ya se ha reproducido
    }
  }

  void _soundConductorHaCancelado(String audioPath) async {
    // Solo reproducir el sonido si no se ha reproducido antes
    if (!_soundConductorHaCanceladoReproducido) {
      print('Intentando reproducir audio: ********$audioPath');
      _player = AudioPlayer();
      await _player.setAsset(audioPath); // Utiliza la ruta completa al archivo de audio
      await _player.play();
      print('Audio reproducido exitosamente****************************');
      _soundConductorHaCanceladoReproducido = true; // Actualiza la bandera para indicar que el sonido ya se ha reproducido
    }
  }

  void _soundBienvenidoABordo(String audioPath) async {
    print('Intentando reproducir audio: ********$audioPath');
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/bienvenido_a_bordo.mp3'); // Utiliza la ruta completa al archivo de audio
    await _player.play();
    print('Audio reproducido exitosamente****************************');
  }

  void _soundBienvenidaABordo(String audioPath) async {
    print('Intentando reproducir audio: ********$audioPath');
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/bienvenida_a_bordo.mp3'); // Utiliza la ruta completa al archivo de audio
    await _player.play();
    print('Audio reproducido exitosamente****************************');
  }

  void soundViajeAceptado(String audioPath) async {
    print('Intentando reproducir audio: ********$audioPath');
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/aceptado.mp3'); // Utiliza la ruta completa al archivo de audio
    await _player.play();
    print('Audio reproducido exitosamente****************************');
  }

  void soundHasLlegadoATuDestino(String audioPath) async {
    print('Intentando reproducir audio: ********$audioPath');
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/has_llegado_sound.mp3'); // Utiliza la ruta completa al archivo de audio
    await _player.play();
    print('Audio reproducido exitosamente****************************');
  }

  void openBottomSheetDiverInfo(){
    showModalBottomSheet(
        context: context,
        builder: (context)=> BottomSheetDriverInfo(
          imageUrl: driver?.image ?? '',
          name:driver?.the01Nombres ?? '',
          apellido: driver?.the02Apellidos ?? '',
          calificacion: driver?.the31Calificacion.toString() ?? '',
          numero_viajes: driver?.the30NumeroViajes.toString() ?? '',
          celular: driver?.the07Celular ?? '',
          placa: driver?.the18Placa ?? '',
          color: driver?.the16Color ?? '',
          servicio: driver?.the19TipoServicio ?? '',
          marca: driver?.the15Marca ?? '',
        ));
  }

}
