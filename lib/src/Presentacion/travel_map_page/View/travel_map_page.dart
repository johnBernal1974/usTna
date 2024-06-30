import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tayrona_usuario/src/models/driver.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonCenterPosition(),
                    _cajonEstadoViaje(_controller.currentStatus),
                  ],
                ),
                _ClickUsuarioServicio(),
                Expanded(child: Container()),
                Visibility(
                  visible: _controller.status == 'accepted' ||
                      _controller.status == 'driver_on_the_way' ||
                      _controller.status == 'driver_is_waiting',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Mostrar el AlertDialog al presionar el botón
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cancelar Viaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              content: const Text('¿Estás seguro de que deseas cancelar el viaje?'),
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
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Cancelar Viaje',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  Widget _cajonEstadoViaje(String status) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16.0),
              topLeft: Radius.circular(16.0),
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
            child: Column(
              children: [
                Text(
                  status ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: blanco,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMapsWidget(){
    return Container(
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _controller.initialPosition,
        onMapCreated: _controller.onMapCreated,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: false,
        markers: Set<Marker>.of(_controller.markers.values),
        polylines: _controller.polylines,
      ),
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {
      });
    }
  }

  Widget _ClickUsuarioServicio() {
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
              color: turquesa,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(48),
                bottomLeft: Radius.circular(48),
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
                  radius: 20,
                  backgroundColor: turquesa,
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: blanco,
                        fontWeight: FontWeight.bold, // Color del texto
                      ),
                    ),
                    Text(
                      placaFormateada,
                      style: const TextStyle(
                        fontSize: 14,
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

  Widget _infoTiempoTranscurrido(String min) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(bottom: 10),
        child: IntrinsicWidth(
          child: Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(left: 25, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: amarillo, // Color del Container
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(48),
                bottomLeft: Radius.circular(48),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 6,
                )
              ],
            ),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Tiempo',
                  style: TextStyle(
                    fontSize: 10,
                    color: negro, // Color del texto
                  ),
                ),
                Text(
                  _controller.seconds.toString(),
                  style: const TextStyle(
                      fontSize: 11,
                      color: negro,
                      fontWeight: FontWeight.bold // Color del texto
                  ),
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
      onTap: (){
        _controller.centerPosition();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: const CircleBorder(),
          color: Colors.white,
          elevation: 2,
          child: Container(
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.location_searching, color: negroLetras, size:30,)),
        ),

      ),
    );
  }
}
