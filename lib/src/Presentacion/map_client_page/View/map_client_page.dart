
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Helpers/customloadingDialog.dart';
import '../../../../providers/auth_provider.dart';
import '../../../colors/colors.dart';
import '../../login_page/View/login_page.dart';
import '../map_client_controller/map_client_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';


class MapClientPage extends StatefulWidget {
  const MapClientPage({super.key});

  @override
  State<MapClientPage> createState() => _MapClientPageState();
}

class _MapClientPageState extends State<MapClientPage> {
  final ClientMapController _controller = ClientMapController();
  late MyAuthProvider _authProvider;
  late bool isVisibleCajonBusquedaOrigenDestino = false;
  late bool isVisibleBotonBuscarVehiculo = false;
  late bool isVisibleADondeVamos = true;
  late bool isVisibleiconoLineaVertical = true;
  late bool isVisibleEspacio = true;
  late bool isVisiblePinBusquedaDestino = false;
  late bool isVisibleBotonPinBusquedaDestino = true;
  late bool isVisibleCerrarIconoBuscarenMapa = false;
  late bool isVisibleCajoncambiandoDireccionDestino = false;
  late bool isVisibleTextoEligetuViaje = true;
  late bool fromVisible = true;
  late bool isLoading = true;
  final _yourGoogleAPIKey = 'AIzaSyDgVNuJAV4Ocn2qq6FoZFVLOCOOm2kIPRE';
  LatLng? selectedToLatLng;
  double iconTop = 0.0;
  final _textController = TextEditingController();
  List<String> searchHistory = [];
  LatLng? tolatlng;
  TextEditingController controller = TextEditingController();
  double minHeight= 170;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      _authProvider = MyAuthProvider();
      _loadSearchHistory();

    });
  }

  @override
  void dispose() {
    super.dispose();
    print('Se ejecuto el dispose********************************************************');
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: grisMapa,
        key: _controller.key,
        drawer: _drawer(),
        body: Stack(
          children: [
            _googleMapsWidget(),
            SafeArea(
              child: Column(
                children: [
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buttonDrawer(),
                      _buttonCenterPosition(),
                    ],
                  ),

                  Expanded(child: Container()),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _letrerosADondeVamos (),
                    ],
                  ),
                  _CajonCambiandoDirecciondeDestino(),

                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _iconBuscarEnElMapaDestino(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _botonBuscarEnElMapaDestino(),
            ),

            Visibility(
              visible: isLoading || _controller.from == null || _controller.from!.isEmpty,
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Cargando...'),
                      SizedBox(height: 10,),
                      CircularProgressIndicator(
                        color: gris,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        )
    );

  }
  // placesAutoCompleteTextField() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: GooglePlaceAutoCompleteTextField(
  //       textEditingController: controller,
  //       googleAPIKey: _yourGoogleAPIKey,
  //       inputDecoration: const InputDecoration(
  //         hintText: "¿A donde vamos?",
  //         border: InputBorder.none,
  //         enabledBorder: InputBorder.none,
  //       ),
  //       debounceTime: 400,
  //       countries: ["co"],
  //       isLatLngRequired: true,
  //       getPlaceDetailWithLatLng: (Prediction prediction) {
  //         print("placeDetails${prediction.lat}");
  //       },
  //       itemClick: (Prediction prediction) {
  //         controller.text = prediction.description ?? "";
  //         controller.selection = TextSelection.fromPosition(
  //             TextPosition(offset: prediction.description?.length ?? 0));
  //       },
  //       seperatedBuilder: const Divider(),
  //       containerHorizontalPadding: 10,
  //       itemBuilder: (context, index, Prediction prediction) {
  //         return Container(
  //           padding: const EdgeInsets.all(10),
  //           child: Row(
  //             children: [
  //               const Icon(Icons.location_on),
  //               const SizedBox(
  //                 width: 7,
  //               ),
  //               Expanded(child: Text(prediction.description ?? ""))
  //             ],
  //           ),
  //         );
  //       },
  //       isCrossBtnShown: true,
  //     ),
  //   );
  // }

  Widget _letrerosADondeVamos () {
    return Visibility(
      visible: isVisibleADondeVamos,
      child: Container(
        height: _calculateContainerHeight(), // Utiliza una función para calcular la altura dinámicamente
        width: double.infinity,
        margin: const EdgeInsets.only(left: 6, right: 6),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 1),
              blurRadius: 8,
            ),
          ],
          color: grisMapa, // Color blanco
        ),
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          children: [
            _tarjetaInfoOrigen(),
            GestureDetector(
              onTap: (){
                _mostrarCajonDeBusqueda(context, (selectedAddress) {
                  // Aquí puedes manejar la selección de la dirección si es necesario
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.white, // Color blanco
                  border: Border.all(color: turquesa, width: 2), // Borde turquesa
                  borderRadius: BorderRadius.circular(48), // Bordes redondeados del TextField
                  boxShadow: [
                    BoxShadow(
                      color: turquesa.withOpacity(0.3), // Color de la sombra
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextField(
                  enabled: false,
                  onTap: () {
                    // Realiza la acción deseada al hacer clic en el campo de texto
                    _mostrarCajonDeBusqueda(context, (selectedAddress) {
                      // Aquí puedes manejar la selección de la dirección si es necesario
                    });
                  },
                  style: const TextStyle(color: turquesa), // Color del texto del TextField
                  decoration: const InputDecoration(
                    hintText: '¿A dónde vamos?',
                    hintStyle: TextStyle(color: turquesa), // Color del hint
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: turquesa,),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _vistaHistorialBusquedas()
          ],
        ),
      ),
    );
  }

  double _calculateContainerHeight() {
    const double minHeight = 170; // Altura mínima del contenedor
    const double itemHeight = 50; // Altura por cada elemento en el historial de búsqueda
    final int itemCount = searchHistory.length; // Cantidad de elementos en el historial de búsqueda
    final double calculatedHeight = minHeight + (itemHeight * itemCount);
    return calculatedHeight;
  }

  Widget _CajonCambiandoDirecciondeDestino (){
    return Visibility(
      visible: isVisibleCajoncambiandoDireccionDestino,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Buscando el lugar de destino en el mapa.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/images/posicion_destino.png', height: 15, width: 15),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _controller.to ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 6,
                    ),
                    onPressed: () {
                      _controller.centerPosition();
                      if (mounted) {
                        setState(() {
                          minHeight = 170;
                          isVisiblePinBusquedaDestino = false;
                          isVisibleBotonPinBusquedaDestino = true;
                          isVisibleCajoncambiandoDireccionDestino = false;
                          isVisibleADondeVamos = true;
                          _controller.requestDriver();
                        });
                      }
                    },
                    child: const Text(
                      'Confirmar el destino',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 6,
                    ),
                    onPressed: () {
                      _controller.centerPosition();
                      //_controller.to = '¿A dónde quieres ir?';
                      if (mounted) {
                        setState(() {
                          minHeight= 170;
                          if (isVisiblePinBusquedaDestino) {
                            isVisiblePinBusquedaDestino = false;
                          }
                          isVisibleCajoncambiandoDireccionDestino = false;
                          isVisibleADondeVamos = true;
                          isVisibleBotonPinBusquedaDestino = true;
                        });
                      }
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleMapsWidget() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300), // Ajusta la duración de la animación según sea necesario
      top: isVisibleCajonBusquedaOrigenDestino ? 0 : 0,
      left: 0,
      right: 0,
      bottom: calcularMargenInferiorMapa(),
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _controller.initialPosition,
        onMapCreated: (GoogleMapController controller) async {
          _controller.onMapCreated(controller);

          // Espera a que el mapa se cargue
          await Future.delayed(const Duration(seconds: 5));

          // Oculta la capa de carga después del retraso
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: false,
        markers: !isVisiblePinBusquedaDestino? Set<Marker>.of(_controller.markers.values): {},
        onCameraMove: (position) {
          _controller.initialPosition = position;
        },
        onCameraIdle: () async {
          if (_controller.currentLocation != null) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
          if (isVisiblePinBusquedaDestino) {
            await _controller.setLocationdraggableInfo();
          }
          await _controller.setLocationdraggableInfoOrigen();
        },
      ),
    );
  }

  Widget _drawer(){
    return Drawer(
      backgroundColor: grisMapa,
      child: ListView(
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                  color:  primary
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.goToProfile();
                    },
                    child: CircleAvatar(
                      backgroundColor: blanco,
                      backgroundImage: _controller.client?.image != null
                          ? CachedNetworkImageProvider(_controller.client!.image!)
                          : null,
                      radius: 45,
                    ),
                  ),


                  Text(_controller.client?.the01Nombres ?? '', style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: blanco
                  ),
                    maxLines: 1,
                  ),
                  Text(_controller.client?.the02Apellidos ?? '', style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: blanco
                  ),
                    maxLines: 1,
                  ),
                ],
              ),

            ),
          ),



          ListTile(
              title: const Text('Historial de viajes', style: TextStyle(
                  fontWeight: FontWeight.w500, color: primary, fontSize: 14
              ),),
              leading: SizedBox (
                width: 20,
                height: 20,
                child: Image.asset("assets/images/historial.png"),
              ),
              onTap:_controller.goToHistorialViajes,

          ),

          ListTile(
            title: const Text('Políticas de privacidad', style: TextStyle(
                fontWeight: FontWeight.w500, color: primary, fontSize: 14
            ),),
            leading: SizedBox (
              width: 20,
              height: 20,
              child: Image.asset("assets/images/privacidad.png"),
            ),
            onTap: _controller.goToPoliticasDePrivacidad,

          ),


          ListTile(
            title: const Text('Contáctanos', style: TextStyle(
                fontWeight: FontWeight.w500, color: primary, fontSize: 14
            ),),
            leading: SizedBox (
              width: 20,
              height: 20,
              child: Image.asset("assets/images/imagen_mujer_call_us.png"),
            ),
            onTap: _controller.goToContactanos,

          ),

          ListTile(
            title: const Text('Compartir aplicación', style: TextStyle(
                fontWeight: FontWeight.w500, color: primary, fontSize: 14
            ),),
            iconColor: gris,
            leading: SizedBox (
              width: 20,
              height: 20,
              child: Image.asset("assets/images/compartir_app.png"),
            ),
            onTap: _controller.goToCompartirAplicacion,

          ),

          const Divider(color: gris, indent: 20, endIndent: 20),

          ListTile(
            title: const Text('Cerrar sesión', style: TextStyle(
                fontWeight: FontWeight.w500, color: primary,fontSize: 14
            ),),
            iconColor: gris,
            leading: SizedBox (
              width: 20,
              height: 20,
              child: Image.asset("assets/images/cerra_sesion.png"),
            ),
            onTap: (){
              Navigator.pop(context);
              _mostrarAlertDialog(context);

            },
          ),

          ListTile(
            title: const Text('Eliminar cuenta', style: TextStyle(
                fontWeight: FontWeight.w500, color: primary,fontSize: 14
            ),),
            leading: SizedBox (
              width: 20,
              height: 20,
              child: Image.asset("assets/images/eliminar_cuenta.png"),
            ),
            onTap: _controller.goToEliminarCuenta,
          ),
        ],
      ),
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {
      });
    }
  }

  Widget _tarjetaInfoOrigen(){
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.all(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Origen', style: TextStyle( fontSize: 14, color: primary, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Image.asset("assets/images/posicion_usuario_negra.png", height: 14, width: 14,),
              const SizedBox(width: 5),
              Expanded(child: Text(_controller.from?? '', style: const TextStyle( fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2,))
            ],
          ),
          const Divider(height: 1, color: grisLogo),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _controller.centerPosition,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: const EdgeInsets.only(right: 10, top: 15),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 2,
          child: Container(
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.location_searching, color: negro, size:22,)),
        ),
      ),
    );
  }

  Widget _buttonDrawer(){
    return GestureDetector(
      onTap: _controller.opendrawer,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: const EdgeInsets.only(left: 10, top: 15),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 2,
          child: Container(
              padding: const EdgeInsets.all(5),
              child: const Icon(Icons.menu, color: negro, size:22,)),

        ),
      ),
    );
  }

  void _mostrarAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cierre de sesión', textAlign: TextAlign.center, style: TextStyle(
              color: negro,
              fontWeight: FontWeight.bold
          ),),
          content: const Text('¿En verdad quieres cerrar la sesión?', style: TextStyle(
              fontSize: 16
          ),),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _authProvider.signOut();
                      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => LoginPage()));
                    },
                    child: const Text('Sí', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: negro
                    ),),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: negro
                    ),),
                  ),

                ],
              ),
            )

          ],
        );
      },
    );
  }

  Widget _botonBuscarEnElMapaDestino(){
    return Visibility(
      visible: isVisibleBotonPinBusquedaDestino,
      child: GestureDetector(
        onTap: (){
          if (mounted) {
            setState(() {
              minHeight = 30;
              isVisiblePinBusquedaDestino = true;
              isVisibleBotonPinBusquedaDestino = false;
              isVisibleCajoncambiandoDireccionDestino = true;
              isVisibleADondeVamos = false;

              // Llamar setLocationdraggableInfo solo cuando el icono es visible
              if (isVisiblePinBusquedaDestino) {
                _controller.setLocationdraggableInfo();
              }
            });
          }
        },
        child: Container(
          height:  ScreenUtil().setSp(45),
          width: ScreenUtil().setSp(110),
          margin: const EdgeInsets.only(bottom: 350),
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24)
            ),
            boxShadow: [
              BoxShadow(
                color: negroLetras,
                offset: Offset(1, 1),
                blurRadius: 6,
              )
            ],
          ),
          alignment: Alignment.bottomRight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/buscar_posicion_card_negro.png', width: 25, height: 15),
            const Text('Buscar en\nel mapa', style: TextStyle(fontSize: 10, color: blanco),)
          ],

          ),
         ),
      ),
    );
  }

  Widget _iconBuscarEnElMapaDestino() {
    return Stack(
      children: [
        // Otros widgets en el Stack
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 110, // 65 es la altura del ícono completo
          left: 0,
          right: 0,
          child: Visibility(
            visible: isVisiblePinBusquedaDestino,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  _mostrarCajonDeBusqueda(context, (selectedAddress) {
                    if (mounted) {
                      setState(() {
                        isVisiblePinBusquedaDestino = false;
                        isVisibleCajonBusquedaOrigenDestino = true;
                        isVisibleTextoEligetuViaje = true;
                        isVisibleBotonBuscarVehiculo = true;
                        isVisibleBotonPinBusquedaDestino = true;
                        isVisibleCajoncambiandoDireccionDestino = false;

                        // Actualizar el campo 'to' con la dirección seleccionada desde el mapa
                        _controller.to = selectedAddress;
                      });
                    }
                  });
                },
                child: Container(
                  child: Image.asset('assets/images/buscar_posicion_card_negro_ok.png', width: 65, height: 65),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }



  //** cambiado ok
  Future<void> _mostrarCajonDeBusqueda(BuildContext context, Function(String) onAddressSelected) async {
    print("Entrando en _mostrarCajonDeBusqueda");

    String? selectedAddress = await showModalBottomSheet<String>(
      isScrollControlled: true,
      context: context,
      backgroundColor: blancoCards,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _cajonDebusqueda(onAddressSelected),
    );

    if (selectedAddress != null) {
      print("Dirección seleccionada (antes de limpiar): $selectedAddress");
      _textController.text = selectedAddress;
      onAddressSelected(selectedAddress);
      print("Dirección seleccionada (después de limpiar): $selectedAddress");
    }
  }


  Widget _cajonDebusqueda(Function(String) onSelectAddress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: const Text(
                "SELECCIONA EL DESTINO DE TU VIAJE",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Tu estás aquí",
                    style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Text(
              _controller.from.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            GooglePlaceAutoCompleteTextField(
              textEditingController: _textController,
              googleAPIKey: _yourGoogleAPIKey,
              inputDecoration: const InputDecoration(
                hintText: '¿A dónde vamos?',
                hintStyle: TextStyle(color: turquesa), // Color del hint
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: turquesa,),
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              countries: const ["co"],
              itemClick: (Prediction prediction) async {
                if (mounted) {
                  setState(() {
                    _textController.text = prediction.description ?? '';
                    _guardarEnHistorial(prediction.description!);
                    // Actualizar el controlador con la dirección seleccionada
                    _controller.to = prediction.description!;
                  });
                }
                // Obtener las coordenadas de la dirección seleccionada
                LatLng? selectedLatLng = await getLatLngFromAddress(prediction.description!);
                if (selectedLatLng != null) {
                  if (mounted) {
                    setState(() {
                      // Actualizar el controlador con las coordenadas
                      _controller.tolatlng = selectedLatLng;
                    });
                  }
                }
                _cerrarBottomSheet(context);
                _controller.requestDriver();
              },

              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          prediction.description ?? "",
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              },
              isCrossBtnShown: true,
            ),
          ],
        ),
      ),
    );
  }


  Widget _vistaHistorialBusquedas(){
    return Container(
      margin: const EdgeInsets.only(bottom: 15, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: searchHistory
                  .map((historyItem) => GestureDetector(
                onTap: () async {
                  String selectedAddress = historyItem;
                  CustomLoadingDialog.show(context); // Mostrar el diálogo de carga
                  print("Tapped on history item: $historyItem");
                  _textController.text = historyItem;

                  //onSelectAddress(selectedAddress);
                  //_controller.to = historyItem;
                  LatLng? selectedLatLng = await getLatLngFromAddress(selectedAddress);

                  if (selectedLatLng != null) {
                    if (mounted) {
                      setState(() {
                        _controller.to = selectedAddress;
                        _controller.tolatlng = selectedLatLng;
                      });
                    }
                    print("LatLng de la dirección seleccionada en el cajon de busqueda: ${_controller.tolatlng}");
                  }
                  CustomLoadingDialog.hide(context);
                  _cerrarBottomSheet(context);
                  _controller.requestDriver();
                },
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.history, color: primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          historyItem,
                          style: const TextStyle(
                            color: negro,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                        ),
                      ),

                    ],
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _cerrarBottomSheet(BuildContext context) {
    _saveSearchHistory();// Guardar historial antes de cerrar
    _textController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _guardarEnHistorial(String searchTerm) async {
    print("Search history before update********************: $searchHistory");
    if (!searchHistory.contains(searchTerm)) {
      // Limitar la cantidad de elementos en el historial a 3
      if (searchHistory.length >= 3) {
        if (mounted) {
          setState(() {
            // Invertir el orden de la lista antes de agregar la búsqueda
            searchHistory = [searchTerm, ...searchHistory.sublist(0, 2)];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Agregar la búsqueda al principio de la lista
            searchHistory.insert(0, searchTerm);
          });
        }
      }
      // Obtener las coordenadas de la dirección seleccionada
      List<Location> locations = await locationFromAddress(searchTerm);
      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _controller.tolatlng = LatLng(locations[0].latitude, locations[0].longitude);
            _controller.to = searchTerm;  // Asegúrate de actualizar también la dirección
          });
          //refresh();
        }
      }
      onSelectAddress(searchTerm); // Llamar a onSelectAddress con la nueva búsqueda
    }
  }

  void onSelectAddress(String address) async{
    print("Selected address ahora con to*****************************: $address");
    if (address != null) {
      // Obtener las coordenadas (LatLng) correspondientes a la dirección seleccionada
      LatLng? selectedLatLng = await getLatLngFromAddress(address);

      if (selectedLatLng != null) {
        if (mounted) {
          setState(() {
            _controller.to = address;
            tolatlng = selectedLatLng;
          });
        }
        print("LatLng de la dirección seleccionada ahora con to*************************: $tolatlng");
      }
    }
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        print("No se encontraron coordenadas para la dirección: $address");
        return null;
      }
    } catch (e) {
      print("Error al obtener coordenadas para la dirección: $address, Error: $e");
      return null;
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        searchHistory = prefs.getStringList('search_history') ?? [];
      });
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('search_history', searchHistory);
  }

  double calcularMargenInferiorMapa() {
    // Ajusta la lógica para calcular el margen inferior del mapa
    // en función del número de elementos en el historial de búsqueda
    //minHeight = 30; // Altura mínima del mapa
    const double marginPerItem = 50; // Margen por cada elemento en el historial de búsqueda

    double calculatedMargin = minHeight + marginPerItem * searchHistory.length;

    // Asegurarse de que el margen calculado no sea menor que la altura mínima
    if (calculatedMargin < minHeight) {
      calculatedMargin = minHeight;
    }

    return calculatedMargin;
  }
}







