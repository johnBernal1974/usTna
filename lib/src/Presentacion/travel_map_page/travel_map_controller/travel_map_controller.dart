
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart' as location;
import 'package:zafiro_cliente/utils/utilsMap.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/geofire_provider.dart';
import '../../../../providers/travel_info_provider.dart';
import '../../../models/driver.dart';
import '../../../models/travel_info.dart';
import '../../commons_widgets/bottom_sheets/bottom_sheet_driver_info.dart';
import 'package:zafiro_cliente/src/models/client.dart';

class TravelMapController{
  late BuildContext context;
  late Function refresh;
  bool isMoto = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  final String _yourGoogleAPIKey = dotenv.get('API_KEY');
  late AudioPlayer _player;
  bool _soundConductorLlegadaReproducido = false;
  bool _soundConductorHaCanceladoReproducido = false;
  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.3445324, -74.3639381),
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
  Position? _position;
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
  int seconds = 0;
  double mts = 0;
  double kms = 0;
  LatLng? _from;
  LatLng? _to;
  LatLng? get from => _from;
  LatLng? get to => _to;
  final StreamController<double> timeRemainingController = StreamController<double>.broadcast();
  String? status = '';
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;



  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    sonidoServicioAceptado ();
    _geofireProvider = GeofireProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _travelInfoProvider = TravelInfoProvider();
    markerDriver = await createMarkerImageFromAssets('assets/images/marcador_driver_zafiro.png');
    markerMotorcycler = await createMarkerImageFromAssets('assets/images/marcador_motos2.png');
    fromMarker = await createMarkerImageFromAssets('assets/images/marker_inicio.png');
    toMarker = await createMarkerImageFromAssets('assets/images/marker_destino.png');
    checkGPS();
    await checkConnectionAndShowSnackbar();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
      refresh();
    });
    _getTravelInfo();
    obtenerStatus();
    _actualizarIsTravelingTrue();
    _position = await Geolocator.getCurrentPosition();
    if (_position != null) {
      initialPosition = CameraPosition(
        target: LatLng(_position!.latitude, _position!.longitude),
        zoom: 20.0,
      );
    }
  }

  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowCard(context, () {
      refresh();
    });
  }

  void sonidoServicioAceptado (){
    if (!soundIsaceptado) {
      soundIsaceptado = true;
      soundViajeAceptado('assets/audio/aceptado.mp3');
    }
  }

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
          currentStatus = '** Viaje aceptado **';
          pickupTravel();
          break;
        case 'driver_on_the_way':
          currentStatus = '** Conductor en camino **';
          break;
        case 'driver_is_waiting':
          currentStatus = '** El Conductor ha llegado **';
          _soundConductorHaLlegado('assets/audio/zafiro_acaba_de_llegar.mp3');
          break;
        case 'started':
          currentStatus = '** El Viaje ha iniciado **';

          startTravel();
          break;
        case 'cancelByDriverAfterAccepted':
          Navigator.pushReplacementNamed(context, 'map_client');
          _soundConductorHaCancelado('assets/audio/conductor_cancelo_servicio.mp3');
          _actualizarIsTravelingFalse();
          Snackbar.showSnackbar(context, key, 'El conductor canceló el servicio');
                          break;
        case 'cancelTimeIsOver':
          Navigator.pushReplacementNamed(context, 'map_client');
          _soundConductorHaCancelado('assets/audio/conductor_cancelo_servicio.mp3');
          _actualizarIsTravelingFalse();
          Snackbar.showSnackbar(context, key, 'El conductor canceló el servicio por tiempo de espera cumplido');
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
    } catch (e) {
      if (kDebugMode) {
        print('Error al borrar el documento: $e');
      }
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
          _driverLatlng = LatLng(latitude, longitude);
          addMarkerDriver('driver', _driverLatlng!.latitude, _driverLatlng!.longitude,'Tu conductor', '', markerDriver);
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
      _from = LatLng(_driverLatlng!.latitude, _driverLatlng!.longitude);
      _to = LatLng(travelInfo!.toLat, travelInfo!.toLng);
      setPolylines(_from!, _to!);
      refresh();
    }
  }

  void finishTravel(){
    if(!isFinishtTravel){
      isFinishtTravel = true;
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
      color: Colors.black87,
      points: points,
      width: 4,
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
    _player.dispose();
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
    _getTravelInfo();
  }

  void checkGPS() async{
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(islocationEnabled){
      if (kDebugMode) {
        print('GPS activado');
      }
    }
    else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        if (kDebugMode) {
          print(' el usuario activo el GPS');
        }
      }
    }
  }


  Future? animateCameraToPosition(double latitude, double longitude)  async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 15.1)
    )
    );
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

  void addMarkerDriver(
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
      anchor: const Offset(0.5, 1.0),
    );

    markers[id] = marker;
  }

  void _soundConductorHaLlegado(String audioPath) async {
    // Solo reproducir el sonido si no se ha reproducido antes
    if (!_soundConductorLlegadaReproducido) {
      _player = AudioPlayer();
      await _player.setAsset(audioPath); // Utiliza la ruta completa al archivo de audio
      await _player.play();
      _soundConductorLlegadaReproducido = true; // Actualiza la bandera para indicar que el sonido ya se ha reproducido
    }
  }

  void _soundConductorHaCancelado(String audioPath) async {
    // Solo reproducir el sonido si no se ha reproducido antes
    if (!_soundConductorHaCanceladoReproducido) {
      _player = AudioPlayer();
      await _player.setAsset(audioPath); // Utiliza la ruta completa al archivo de audio
      await _player.play();
      _soundConductorHaCanceladoReproducido = true; // Actualiza la bandera para indicar que el sonido ya se ha reproducido
    }
  }

  void soundViajeAceptado(String audioPath) async {
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/aceptado.mp3'); // Utiliza la ruta completa al archivo de audio
    await _player.play();
  }


  void openBottomSheetDiverInfo(){
    showModalBottomSheet(
        context: context,
        builder: (context)=> BottomSheetDriverInfo(
          imageUrl: driver?.image ?? '',
          name:driver?.the01Nombres ?? '',
          apellido: driver?.the02Apellidos ?? '',
          calificacion: driver?.the31Calificacion.toString() ?? '',
          numeroViajes: driver?.the30NumeroViajes.toString() ?? '',
          celular: driver?.the07Celular ?? '',
          placa: driver?.the18Placa ?? '',
          color: driver?.the16Color ?? '',
          servicio: driver?.the19TipoServicio ?? '',
          marca: driver?.the15Marca ?? '',
          idDriver: driver?.id ?? '',
        ));
  }

}
