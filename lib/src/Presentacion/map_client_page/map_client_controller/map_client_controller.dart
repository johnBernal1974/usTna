import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/geofire_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zafiro_cliente/src/models/client.dart';
import 'package:zafiro_cliente/utils/utilsMap.dart';
import '../../../../providers/push_notifications_provider.dart';

class ClientMapController {
  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.8470616, -74.0743461),
    zoom: 20.0,

  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position? _position;
  late StreamSubscription<Position> _positionStream;
  late BitmapDescriptor markerClient;
  late BitmapDescriptor markerDriver;
  late GeofireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late StreamSubscription<DocumentSnapshot<Object?>> _clientInfoSuscription;
  late StreamSubscription<List<DocumentSnapshot>>? _driversSubscription;
  late PushNotificationsProvider _pushNotificationsProvider;

  ClientMapController() {
    _initializePositionStream();
  }

  Client? client;
  String? from;
  LatLng? fromlatlng;
  String? to;
  LatLng? tolatlng;
  LatLng? currentLocation;

  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false; //**para validar el estado de conexion a internet
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;  // Suscripción para escuchar cambios en conectividad

  // Inicializar _positionStream
  void startPositionStream() {
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      _position = position;
    });
  }

  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    markerClient = await createMarkerImageFromAssets('assets/images/marker_inicio.png');
    markerDriver = await createMarkerImageFromAssets('assets/images/marcador_driver_zafiro.png');

    checkGPS();

    await checkConnectionAndShowSnackbar();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
      refresh();
    });
    // Obtener la posición actual y establecerla como posición inicial
    _position = await Geolocator.getCurrentPosition();
    if (_position != null) {
      initialPosition = CameraPosition(
        target: LatLng(_position!.latitude, _position!.longitude),
        zoom: 20.0,
      );
    }
    saveToken();
    getClientInfo();
  }

  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowCard(context, () {
      // Callback para manejar la reconexión a Internet
      refresh();
    });
  }
  void _initializePositionStream() {
    // Inicializa tu _positionStream aquí
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      // Manejar la posición actualizada
    });
  }

  Future<Null> setLocationdraggableInfo() async {
    double lat = initialPosition.target.latitude;
    double lng = initialPosition.target.longitude;
    List<Placemark> address = await placemarkFromCoordinates(lat, lng);

    if (address.isNotEmpty) {
      String? direction = address[0].thoroughfare;
      String? street = address[0].subThoroughfare;
      String? city = address[0].locality;
      String? department = address[0].administrativeArea;

      to = '$direction #$street, $city, $department';
      tolatlng = LatLng(lat, lng);
      refresh();
    }
    }

  void saveToken() {
    final user = _authProvider.getUser();
    if (user != null) {
      _pushNotificationsProvider.saveToken(user.uid);
    }
  }

  Future<Null> setLocationdraggableInfoOrigen() async {
    if (_position != null) {
      double lat = _position!.latitude;
      double lng = _position!.longitude;
      List<Placemark> address = await placemarkFromCoordinates(lat, lng);

      if (address.isNotEmpty) {
        String? direction = address[0].thoroughfare;
        String? street = address[0].subThoroughfare;
        String? city = address[0].locality;
        String? department = address[0].administrativeArea;
        from = '$direction #$street, $city, $department';
        fromlatlng = LatLng(lat, lng);
        refresh();
      }
    }
  }

  void getClientInfo() {
    final user = _authProvider.getUser();
    if (user != null) {
      Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(user.uid);
      _clientInfoSuscription = clientStream.listen((DocumentSnapshot document) {
        if (document.data() != null) {
          client = Client.fromJson(document.data() as Map<String, dynamic>);
          //refresh();
        }
      });
    }
  }


  void getNearbyDrivers() {
    if (_position != null) {
      Stream<List<DocumentSnapshot>> stream =
      _geofireProvider.getNearbyDrivers(_position!.latitude, _position!.longitude, 1);

      _driversSubscription = stream.listen((List<DocumentSnapshot> documentList) {
        // Limpiar marcadores de conductores existentes
        List<MarkerId> driverMarkersToRemove = [];

        for (MarkerId m in markers.keys) {
          if (m.value != 'client') {
            driverMarkersToRemove.add(m);
          }
        }

        for (var m in driverMarkersToRemove) {
          markers.remove(m);
        }

        // Mantener el marcador del cliente
        if (_position != null) {
          addMarker(
            'client',
            _position!.latitude,
            _position!.longitude,
            'Tu posición',
            "",
            markerClient,
          );
        }

        for (DocumentSnapshot d in documentList) {
          Map<String, dynamic> positionData = d.get('position');
          if (positionData.containsKey('geopoint')) {
            GeoPoint geoPoint = positionData['geopoint'];
            double latitude = geoPoint.latitude;
            double longitude = geoPoint.longitude;

            addMarkerDriver(
              d.id,
              latitude,
              longitude,
              'Conductor disponible',
              "",
              markerDriver,
            );
          } else {
            if (kDebugMode) {
              print('GeoPoint is null or not found.');
            }
          }
        }

        // Actualizar el estado para reflejar los cambios en el mapa
        refresh();
      });
    }
  }


  void dispose(){
    _positionStream.cancel();
    _clientInfoSuscription.cancel();
    _driversSubscription?.cancel();
    _connectivitySubscription?.cancel();
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = (await Geolocator.getLastKnownPosition())!;
      if (_position != null) {
        centerPosition();

        addMarker(
            'client',
            _position!.latitude,
            _position!.longitude,
            "Tu posición", "",
            markerClient
        );

        getNearbyDrivers();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en la localizacion: $error');
      }
    }
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    }
  }

  void checkGPS() async{
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(islocationEnabled){
      updateLocation();
    }
    else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
      }
    }
  }

  void opendrawer(){
    key.currentState?.openDrawer();
  }
  void goToHistorialViajes(){
    Navigator.pushNamed(context, "historial_viajes");
  }
  void goToPoliticasDePrivacidad(){
    Navigator.pushNamed(context, "politicas_de_privacidad");
  }
  void goToContactanos(){
    Navigator.pushNamed(context, "contactanos");
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

  void requestDriver() {
    if (fromlatlng != null && tolatlng != null) {
      // Verificar si las coordenadas de origen y destino son iguales
      if (from == to) {
        // Mostrar un Snackbar informando que las coordenadas son iguales
        if (key.currentState != null) {
          Snackbar.showSnackbar(context, key, 'La posición de origen es la misma que el destino. Verifica el destino e intentalo nuevamente');
        }
      } else {
        // Si las coordenadas no son iguales, navega a la página de viaje
        Navigator.pushNamed(context, "travel_info_page", arguments: {
          'from': from,
          'to': to,
          'fromlatlng': fromlatlng,
          'tolatlng': tolatlng,
        });
      }
    } else {
      // Si no se han seleccionado las coordenadas, mostrar un Snackbar
      if (key.currentState != null) {
        Snackbar.showSnackbar(context, key, 'Debes seleccionar el lugar de origen y destino');
      }
    }
  }



  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
       return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 16,
      ),
    ));
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
      // rotation: _position?.heading ?? 0,
    );

    markers[id] = marker;
  }
  void addMarkerDriver(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
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
      // rotation: _position?.heading ?? 0,
    );

    markers[id] = marker;
  }
}

