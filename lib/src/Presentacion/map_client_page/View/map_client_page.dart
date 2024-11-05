
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Helpers/customloadingDialog.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../../login_page/View/login_page.dart';
import '../map_client_controller/map_client_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
  final String _yourGoogleAPIKey = dotenv.get('API_KEY');
  LatLng? selectedToLatLng;
  double iconTop = 0.0;
  final _textController = TextEditingController();
  List<String> searchHistory = [];
  LatLng? tolatlng;
  double bottomMaps= 270;
  final ConnectionService connectionService = ConnectionService();



  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      _authProvider = MyAuthProvider();
      _checkConnection();
      _loadSearchHistory();

    });
  }

  Future<void> _checkConnection() async {
    await connectionService.checkConnectionAndShowCard(context, () {
      // Callback para manejar la restauración de la conexión
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                    _cajonCambiandoDirecciondeDestino(),

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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Cargando...'),
                        SizedBox(height: 10.r,),
                        const CircularProgressIndicator(
                          color: gris,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _letrerosADondeVamos () {
    return Visibility(
      visible: isVisibleADondeVamos,
      child: Container(
        height: 300.r, // Utiliza una función para calcular la altura dinámicamente
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),

            boxShadow: [
              BoxShadow(
                color: negro.withOpacity(0.4),
                offset:Offset(0, 8.r),
                blurRadius: 9.r,
              ),
            ],
            color: blancoCards
        ),
        padding: EdgeInsets.only(top: 15.r),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.r, right: 20.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estás aquí', style: TextStyle( fontSize: 14.r, fontWeight: FontWeight.w500, color: negro)),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/marker_inicio.png', // La imagen original
                        height: 18.r, // Ajusta la altura de la imagen
                        width: 18.r, // Ajusta el ancho de la imagen
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _controller.from ?? '',
                          style: TextStyle(
                              fontSize: 14.r,
                              fontWeight: FontWeight.bold,
                              color: negro
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            // Verificar conexión a Internet antes de ejecutar la acción
            connectionService.hasInternetConnection().then((hasConnection) {
              if (hasConnection) {
                // Llama a _mostrarCajonDeBusqueda inmediatamente
                _mostrarCajonDeBusqueda(context, (selectedAddress) {});
              } else {
                // Llama a alertSinInternet inmediatamente si no hay conexión
                alertSinInternet();
              }
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.r, horizontal: 15.r),
            decoration: BoxDecoration(
              color: Colors.white, // Color de fondo del contenedor
              borderRadius: BorderRadius.circular(24), // Esquinas redondeadas
              border: Border.all(color: primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.8), // Color de la sombra
                  offset: Offset(0, 2.r),
                  blurRadius: 7.r,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.r), // Espaciado interno
              child: Row(
                children: [
                  const Icon(Icons.search, color: negro), // Icono de búsqueda
                  SizedBox(width: 10.r), // Espacio entre el icono y el texto
                  const Expanded(
                    child: Text(
                      '¿A dónde vamos?', // Texto predeterminado
                      style: TextStyle(
                        color: negro,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        _vistaHistorialBusquedas()
          ],
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


  Widget _cajonCambiandoDirecciondeDestino (){
    return Visibility(
      visible: isVisibleCajoncambiandoDireccionDestino,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: blancoCards,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5.r,
              blurRadius: 7.r,
              offset: Offset(0, 3.r), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Buscando el lugar de destino en el mapa.',
                style: TextStyle(
                  fontSize: 18.r,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.r),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on, // Cambia la imagen por el icono de bandera
                        color: Colors.green, // Color verde para el icono
                        size: 18.r, // Ajusta el tamaño del icono al mismo que tenía la imagen
                      ),
                      SizedBox(width: 10.r),
                      Expanded(
                        child: Text(
                          _controller.to ?? '',
                          style: TextStyle(
                            fontSize: 14.r,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )

              ),
              SizedBox(height: 20.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      elevation: 6,
                    ),
                    onPressed: () {
                      _controller.centerPosition();
                      setState(() {
                        isVisiblePinBusquedaDestino = false;
                        isVisibleBotonPinBusquedaDestino = true;
                        isVisibleCajoncambiandoDireccionDestino = false;
                        isVisibleADondeVamos = true;
                        _controller.requestDriver();
                      });
                    },
                    child:Text(
                      'Confirmar el destino',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.r,
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
                          bottomMaps= 270;
                          if (isVisiblePinBusquedaDestino) {
                            isVisiblePinBusquedaDestino = false;
                          }
                          isVisibleCajoncambiandoDireccionDestino = false;
                          isVisibleADondeVamos = true;
                          isVisibleBotonPinBusquedaDestino = true;
                        });
                      }
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.r,
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
      bottom: bottomMaps,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _controller.initialPosition,
        onMapCreated: (GoogleMapController controller) async {
          _controller.onMapCreated(controller);

          // Espera a que el mapa se cargue
          await Future.delayed(const Duration(seconds: 5));

          // Oculta la capa de carga después del retraso
          setState(() {
            isLoading = false;
          });
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
            setState(() {
              isLoading = false;
            });
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
      backgroundColor: blancoCards,
      child: ListView(
        children: [
          SizedBox(
            height: 250.r,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                  color: primary
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
                          ? CachedNetworkImageProvider(_controller.client!.image)
                          : null,
                      radius: 45,
                    ),
                  ),

                  Text(_controller.client?.the01Nombres ?? '', style: TextStyle(
                      fontSize: 18.r, fontWeight: FontWeight.w900, color: blanco
                  ),
                    maxLines: 1,
                  ),
                  Text(_controller.client?.the02Apellidos ?? '', style: TextStyle(
                      fontSize: 13.r, fontWeight: FontWeight.w600, color: blancoCards
                  ),
                    maxLines: 1,
                  ),
                ],
              ),

            ),
          ),

          ListTile(
            leading: const Icon(Icons.history, color: primary), // Icono para Historial de viajes
            title: Text('Historial de viajes', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
            onTap: _controller.goToHistorialViajes,
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip, color: primary), // Icono para Políticas de privacidad
            title: Text('Políticas de privacidad', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
            onTap: _controller.goToPoliticasDePrivacidad,
          ),

          ListTile(
            leading: const Icon(Icons.contact_mail, color: primary), // Icono para Contáctanos
            title: Text('Contáctanos', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
            onTap: _controller.goToContactanos,
          ),

          ListTile(
            leading: const Icon(Icons.share, color: primary), // Icono para Compartir aplicación
            title: Text('Compartir aplicación', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
            iconColor: gris,
            onTap: _controller.goToCompartirAplicacion,
          ),

          const Divider(color: grisMedio),

          ListTile(
            leading: const Icon(Icons.logout, color: primary), // Icono para Cerrar sesión
            title: Text('Cerrar sesión', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
            iconColor: gris,
            onTap: () {
              Navigator.pop(context);
              _mostrarAlertDialog(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: primary), // Icono para Eliminar cuenta
            title: Text('Eliminar cuenta', style: TextStyle(
                fontWeight: FontWeight.w400, color: negro, fontSize: 16.r
            )),
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

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _controller.centerPosition,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.only(right: 10.r, top: 15.r),
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
                color: blanco,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.location_searching, color: negro, size:20.r,)),
        ),
      ),
    );
  }

  Widget _buttonDrawer(){
    return GestureDetector(
      onTap: _controller.opendrawer,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.only(right: 10.r, top: 15.r, left: 10.r),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 5,
          child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0.0, 15.0),
                    blurRadius: 25,
                    color: gris,
                  )
                ],
                color: blanco,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(5),
              child: Icon(Icons.menu, color: negro, size:20.r)),

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
          content: Text('¿En verdad quieres cerrar la sesión?', style: TextStyle(
              fontSize: 16.r
          ),),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _authProvider.signOut();
                      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const LoginPage()));
                    },
                    child: Text('Sí', style: TextStyle(
                        fontSize: 16.r, fontWeight: FontWeight.bold, color: negro
                    ),),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No', style: TextStyle(
                        fontSize: 16.r, fontWeight: FontWeight.bold, color: negro
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
        onTap: () async {
          // Verificar conexión a Internet antes de ejecutar la acción
          bool hasConnection = await connectionService.hasInternetConnection();

          if (hasConnection) {
            // Si hay conexión, ejecuta la acción de ir a "Olvidaste tu contraseña"
            if (mounted) {
              setState(() {
                bottomMaps = 170;
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
          } else {
            alertSinInternet();
          }
        },

        child: Container(
          height:  ScreenUtil().setSp(45),
          width: ScreenUtil().setSp(110),
          margin: EdgeInsets.only(bottom: 350.r),
          padding: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24)
            ),

            boxShadow: [
              BoxShadow(
                offset: Offset(5.0, 3.0),
                blurRadius: 20,
                color: gris,
              )
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/buscar_posicion_card_negro.png', width: 25.r, height: 25.r),
              Text('Buscar en\nel mapa', style: TextStyle(fontSize: 12.r, color: blanco, fontWeight: FontWeight.w500, height: 1),)
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
          top: MediaQuery.of(context).size.height / 2 - 115, // 40 es la mitad de la altura del icono (80)
          left: 0,
          right: 0,
          child: Visibility(
            visible: isVisiblePinBusquedaDestino,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  _mostrarCajonDeBusqueda(context, (selectedAddress) {
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
                  });
                },
                child: Image.asset('assets/images/buscar_posicion_card_negro_ok.png', width: 50.r, height: 50.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarCajonDeBusqueda(BuildContext context, Function(String) onAddressSelected) async {
    String? selectedAddress = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        child: _cajonDebusqueda(onAddressSelected),
      ),
    );
    if (selectedAddress != null) {
      _textController.text = selectedAddress;
      onAddressSelected(selectedAddress);
    }
  }

  Widget _cajonDebusqueda (Function(String) onSelectAddress){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(5.r),
          margin: EdgeInsets.only(left: 10.r, right: 10.r, top: 60.r),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.all(Radius.circular(1)),
            boxShadow: [
              BoxShadow(
                color: gris,
                offset: Offset(1, 1.r),
                blurRadius: 6.r,
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      //imagen de posicion inicial y linea vertical
                      Visibility(
                        visible: isVisibleiconoLineaVertical,
                        child: Column(
                          children: [
                            Image.asset('assets/images/marker_inicio.png', height: 25.r, width: 15.r,),
                            Container(
                              color: negroLetras,
                              width: 1, height: 65,
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/marker_destino.png', height: 25.r, width: 20.r),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 5.r, right: 10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            Visibility(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Origen', style: TextStyle(color: blanco,fontSize: 14.r, fontWeight: FontWeight.bold)),
                                  Container(
                                    margin: EdgeInsets.only( top: 10.r),
                                    width: MediaQuery.of(context).size.width.round() * 0.80,
                                    child:GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.only(left: 8.r, top: 10.r, bottom: 10.r),
                                        decoration: BoxDecoration(
                                          color: blanco,
                                          borderRadius: BorderRadius.circular(24),
                                          border:Border.all(color: primary),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withOpacity(0.3), // Color de la sombra
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(_controller.from ?? '',
                                          style: TextStyle(color: negroLetras,fontSize: 13.r, fontWeight: FontWeight.w600,), maxLines: 1,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: isVisibleEspacio,
                          child: SizedBox(height: 10.r)),
                      Container(
                        margin:EdgeInsets.only(left: 5.r, right: 10.r,bottom: 10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            Text('Destino', style: TextStyle(color: blanco,fontSize: 12.r, fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width.round() * 0.80,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 50.r,
                                  margin: EdgeInsets.only(top: 10.r),
                                  padding: EdgeInsets.only(bottom: 10.r),
                                  decoration: BoxDecoration(
                                    color: grisClaro,
                                    borderRadius: BorderRadius.circular(24),
                                    border:Border.all(color: grisMedio),
                                  ),
                                  child: Form(
                                    child: GooglePlacesAutoCompleteTextFormField(
                                      autofocus: true,
                                      textCapitalization: TextCapitalization.sentences,
                                      cursorColor: Colors.black,
                                      textEditingController: _textController,
                                      googleAPIKey: _yourGoogleAPIKey,
                                      countries: const ["co"],
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.r,
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      maxLines: 1,
                                      itmClick: (Prediction prediction) async {
                                        setState(() {
                                          _textController.text = prediction.description ?? '';
                                          _guardarEnHistorial(prediction.description!);

                                          // Actualizar el controlador con la dirección seleccionada
                                          _controller.to = prediction.description!;
                                        });
                                        // Obtener las coordenadas de la dirección seleccionada
                                        LatLng? selectedLatLng = await getLatLngFromAddress(prediction.description!);
                                        if (selectedLatLng != null) {
                                          setState(() {
                                            // Actualizar el controlador con las coordenadas
                                            _controller.tolatlng = selectedLatLng;
                                          });
                                        }
                                        if(context.mounted){
                                          _cerrarBottomSheet(context);
                                        }
                                        _controller.requestDriver();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.r, bottom: 10.r, right: 15.r),
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {
              _cerrarBottomSheet(context);
            },
            child: Container(
              margin: EdgeInsets.only(top: 15.r, right: 10.r),
              width: 80.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.cancel_rounded,size: 20.r,),
                  const Text('Cerrar',style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _vistaHistorialBusquedas() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.r, top: 10.r),
        child: searchHistory.isEmpty
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.r), // Ajusta el padding según sea necesario
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 60.r, color: primary), // Icono para indicar que no hay historial
                SizedBox(height: 10.r),
                Text(
                  "Aún no tienes un historial de viajes recientes.",
                  style: TextStyle(fontSize: 14.r, color: negro),
                ),
              ],
            ),
          ),
        )
            : SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: searchHistory
                .map((historyItem) => GestureDetector(
              onTap: () async {
                String selectedAddress = historyItem;
                CustomLoadingDialog.show(context); // Mostrar el diálogo de carga
                _textController.text = historyItem;
                LatLng? selectedLatLng = await getLatLngFromAddress(selectedAddress);

                if (selectedLatLng != null) {
                  setState(() {
                    _controller.to = selectedAddress;
                    _controller.tolatlng = selectedLatLng;
                  });
                  if(context.mounted){
                    CustomLoadingDialog.hide(context);
                  }
                  _controller.requestDriver();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.r, horizontal: 6.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.history, color: primary, size: 16,),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        historyItem,
                        style: TextStyle(color: negro, fontSize: 12.r, fontWeight: FontWeight.w500),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ))
                .toList(),
          ),
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
    if (!searchHistory.contains(searchTerm)) {
      // Limitar la cantidad de elementos en el historial a 3
      if (searchHistory.length >= 3) {
        setState(() {
          // Invertir el orden de la lista antes de agregar la búsqueda
          searchHistory = [searchTerm, ...searchHistory.sublist(0, 2)];
        });
      } else {
        setState(() {
          // Agregar la búsqueda al principio de la lista
          searchHistory.insert(0, searchTerm);
        });
      }
      // Obtener las coordenadas de la dirección seleccionada
      List<Location> locations = await locationFromAddress(searchTerm);
      if (locations.isNotEmpty) {
        setState(() {
          _controller.tolatlng = LatLng(locations[0].latitude, locations[0].longitude);
          _controller.to = searchTerm;  // Asegúrate de actualizar también la dirección
          refresh();
        });
      }
      onSelectAddress(searchTerm); // Llamar a onSelectAddress con la nueva búsqueda
    }
  }

  void onSelectAddress(String address) async{
    // Obtener las coordenadas (LatLng) correspondientes a la dirección seleccionada
    LatLng? selectedLatLng = await getLatLngFromAddress(address);
    if (selectedLatLng != null) {
      setState(() {
        _controller.to = address;
        tolatlng = selectedLatLng;
      });
    }
    }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        if (kDebugMode) {
          print("No se encontraron coordenadas para la dirección: $address");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener coordenadas para la dirección: $address, Error: $e");
      }
      return null;
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('search_history', searchHistory);
  }

}







