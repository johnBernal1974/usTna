
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zafiro_cliente/src/models/driver.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../travel_map_controller/travel_map_controller.dart';

class TravelMapPage extends StatefulWidget {
  const TravelMapPage({super.key});

  @override
  State<TravelMapPage> createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {

  late TravelMapController _controller;
  Driver? driver;
  bool _soundAceptado = false;
  final ConnectionService connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
    _controller = TravelMapController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
    if (!_soundAceptado) {
      _controller.soundViajeAceptado('assets/audio/viaje_aceptado.mp3');
      _soundAceptado = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _googleMapsWidget(),
                SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buttonCenterPosition(),
                        ],
                      ),
                      Expanded(child: Container()),
                      _clickUsuarioServicio(),
                      SizedBox(height: 5.r),
                      _cancelarViaje(),
                      SizedBox(height: 15.r),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _cajonInformativo(screenWidth),
        ],
      ),
    );
  }

  Widget _cajonEstadoViaje(String status) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      width: double.infinity,
      color: primary,
      child: Column(
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 20.r,
              fontWeight: FontWeight.w900,
              color: blanco,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelarViaje() {
    return Visibility(
      visible: _controller.status == 'accepted' ||
          _controller.status == 'driver_on_the_way' ||
          _controller.status == 'driver_is_waiting',
      child: Padding(
        padding: EdgeInsets.only(top: 5.r),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              // Verificar conexión a Internet antes de ejecutar la acción
              connectionService.hasInternetConnection().then((hasConnection) {
                if (hasConnection) {
                  // Llama a _mostrarCajonDeBusqueda inmediatamente
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Cancelar Viaje', style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold)),
                        content: const Text('¿En verdad deseas cancelar el viaje?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Cerrar el AlertDialog sin realizar ninguna acción
                              Navigator.of(context).pop();
                            },
                            child: const Text('NO'),
                          ),
                          TextButton(
                            onPressed: () {
                              _controller.cancelTravelByClient();
                            },
                            child: const Text('SI'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Llama a alertSinInternet inmediatamente si no hay conexión
                  alertSinInternet();
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.r),
                      topLeft: Radius.circular(40.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.white, size: 16.r),
                        const SizedBox(width: 5),
                        Text(
                          'Cancelar Viaje',
                          style: TextStyle(
                            fontSize: 12.r,
                            fontWeight: FontWeight.w900,
                            color: blanco,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future alertSinInternet (){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _controller.initialPosition,
      onMapCreated: _controller.onMapCreated,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      tiltGesturesEnabled: false,
      markers: Set<Marker>.of(_controller.markers.values),
      polylines: _controller.polylines,
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _clickUsuarioServicio() {
    String placaCompleta = _controller.driver?.the18Placa ?? '';
    String placaFormateada = '';
    if (placaCompleta.length == 6) {
      String letras = placaCompleta.substring(0, 3);
      String numeros = placaCompleta.substring(3);
      placaFormateada = '$letras-$numeros';
    } else {
      // Manejar el caso en el que la placa no tenga 6 caracteres
      placaFormateada = placaCompleta; // O asignar un valor por defecto
    }

    return GestureDetector(
      onTap: () {
        if (['accepted', 'driver_on_the_way', 'driver_is_waiting'].contains(_controller.travelInfo?.status)) {
          _controller.openBottomSheetDiverInfo();
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(48.r),
                bottomLeft: Radius.circular(48.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: primary,
                  backgroundImage: _controller.driver?.image != null
                      ? NetworkImage(_controller.driver!.image)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.driver?.the01Nombres ?? '',
                      style: TextStyle(
                        fontSize: 11.r,
                        color: blanco,
                        fontWeight: FontWeight.bold, // Color del texto
                      ),
                    ),
                    Text(
                      placaFormateada,
                      style: TextStyle(
                        fontSize: 14.r,
                        color: blanco,
                        fontWeight: FontWeight.bold, // Color del texto
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _controller.centerPosition,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.only(right: 10.r, top: 15.r, left: 15.r),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 2,
          child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0.0, 15.0),
                    blurRadius: 25,
                    color: gris,
                  )
                ],
                color: blancoCards,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.location_searching, color: negro, size:20.r,)),
        ),
      ),
    );
  }

  Widget _cajonInformativo(double screenWidth) {
    final formatCurrency = NumberFormat("#,##0", "es_CO");
    return Container(
      width: screenWidth,
      color: blanco,
      child: Column(
        children: [
          _cajonEstadoViaje(_controller.currentStatus),
          SizedBox(height: 5.r),
          Container(
            padding: const EdgeInsets.only(left: 6, bottom: 6, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/peaje2.png',
                  height: 80.r,
                  width: 80.r,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$ ${formatCurrency.format(_controller.travelInfo?.tarifa ?? 0)}',
                        style: TextStyle(
                          fontSize: 20.r,
                          fontWeight: FontWeight.w900,
                          color: negro,
                        ),
                      ),
                      Text(
                        'Información Importante',
                        style: TextStyle(
                          fontSize: 14.r,
                          fontWeight: FontWeight.bold,
                          color: rojo,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Los peajes que lleguen a existir en la ruta son a cargo del usuario, no están incluidos en la tarifa.',
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: FontWeight.w600,
                          color: negro,
                          height: 1
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
