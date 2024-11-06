import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zafiro_cliente/src/Presentacion/travel_info_page/travel_info_Controller/travel_info_Controller.dart';
import '../../../Helpers/Validators/FormValidators.dart';
import '../../../providers/conectivity_service.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';


class ClientTravelInfoPage extends StatefulWidget {
  const ClientTravelInfoPage({super.key});

  @override
  State<ClientTravelInfoPage> createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {

  final TravelInfoController _controller = Get.put(TravelInfoController());
  late bool isVisibleCheckCarro = true;
  late bool isVisibleCheckMoto = false;
  late bool isVisibleCheckEncomienda = false;
  late bool isVisibleTarjetaEncomiendas = false;
  late bool isVisibleTarjetaSolicitandoConductor = false;
  late String formattedTarifa;
  int? tarifa;
  bool _isSearching = false;
  bool _isChecked = false;
  bool _aceptoTerminos = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  String? tipoServicio ;
  late bool isVisibleCajonApuntesAlConductor = false;
  final TextEditingController _con = TextEditingController();
  String? apuntesAlConductor;
  String? tipoServicioSeleccionado;
  final ConnectionService connectionService = ConnectionService();



  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      setState(() {});
    });
    _verificarAceptoTerminos();

  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    tarifa = _controller.total?.toInt() ?? 0;
    formattedTarifa= FormatUtils.formatCurrency(tarifa!);
    String from = _controller.from;
    String to = _controller.to;
    return WillPopScope(
      onWillPop: () async {
        await _controller.deleteTravelInfo();
        return true;
      },
      child: Scaffold(
          backgroundColor: grisMapa,
          key: _controller.key,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _googleMapsWidget(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child:  _cardInfoViaje(from, to),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _buttonVolverAtras(),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: _tarjetaInfoEncomienda(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _tarjetaSolicitandoConductor(),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child:  _apuntesAlConductor(),
              )
            ],

          ),

        ),
    );
  }

  void refresh(){
    if(mounted){
      setState(() {
      });
    }

  }

  Future<void> _verificarAceptoTerminos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _aceptoTerminos = prefs.getBool('aceptoTerminos') ?? false;
      });
    }
  }

  Future<void> _guardarAceptoTerminos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aceptoTerminos', true);
    if (mounted) {
      setState(() {
        _aceptoTerminos = true;
      });
    }

  }

  Future<void> _mostrarAlerta() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta', style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold)),
          content: const Text('Para continuar debes aceptar los Términos y Condiciones'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _googleMapsWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      //margin: const EdgeInsets.only(bottom: 420),
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

  Widget _buttonVolverAtras(){
    return SafeArea(
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).pop(); // Agrega esta línea para manejar el evento de retroceso
        },
        child: Container(
          margin: EdgeInsets.only(right: 10.r,  left: 10.r),
          child: Card(
            shape: const CircleBorder(),
            surfaceTintColor: blancoCards,
            elevation: 2,
            child: Container(
                padding: EdgeInsets.all(5.r),
                child: Icon(Icons.arrow_back, color: negroLetras, size:20.r,)),

          ),
        ),
      ),
    );
  }

  Widget _cardInfoViaje(String from, String to){
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: double.infinity,
      decoration: BoxDecoration(
          color: blancoCards,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30)
          ),
          boxShadow: [BoxShadow(
            color: gris,
            offset: const Offset(1,1),
            blurRadius: 10.r,
          )]
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15.r, left: 25.r, right: 25.r),
            child: Row(
              children: [
                Image.asset('assets/images/marker_inicio.png', height: 15.r, width: 15.r),
                SizedBox(width: 5.r),
               Expanded(child: Text(from, style: TextStyle(fontSize: 12.r, color: negro), maxLines: 1))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 25.r, right: 25.r),
            child: Row(
              children: [
                Image.asset('assets/images/marker_destino.png', height: 15.r, width: 15.r),
                SizedBox(width: 5.r),
                Expanded(child: Text(to, style: TextStyle( fontWeight: FontWeight.w900, fontSize: 12.r, color: negro), maxLines: 1))
              ],
            ),
          ),

          const Divider(height: 2, color: grisMedio, indent: 15, endIndent: 15),

          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        headerText(text:'Distancia', fontSize: 10.r, color: negro, fontWeight: FontWeight.w500),
                        headerText(text: _controller.km ?? '', fontSize: 14.r, color: negro, fontWeight: FontWeight.w900),
                      ],
                    ),

                    Column(
                      children: [
                        headerText(text:'Duración', fontSize: 10.r, color: negro, fontWeight: FontWeight.w500),
                        headerText(text: _controller.min ?? '', fontSize: 14.r, color: negro, fontWeight: FontWeight.w900),
                      ],
                    ),
                  ],
                ),

                Container(
                    width: 200.r,
                    padding: EdgeInsets.all(10.r),
                    child: headerText(text: formattedTarifa, fontSize: 26.r, color: negro, fontWeight: FontWeight.w900)
                ),
              ],
            ),
          ),
          const Divider(height: 2, color: grisMedio, indent: 15, endIndent: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  _controller.guardarTipoServicio("Transporte");
                  if (mounted) {
                    setState(() {
                      isVisibleCheckCarro = true;
                      isVisibleCheckMoto = false;
                      isVisibleCheckEncomienda = false;
                    });
                  }
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.all(15.r),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5.r)),
                          height: !isVisibleCheckCarro ? ScreenUtil().setSp(45.r) : ScreenUtil().setSp(65.r),
                          width: !isVisibleCheckCarro ? ScreenUtil().setSp(75.r) : ScreenUtil().setSp(115.r),
                          decoration: BoxDecoration(
                            color: blanco,
                            borderRadius: const BorderRadius.all(Radius.circular(12),
                            ),
                              border:  !isVisibleCheckCarro? Border.all(color: blancoCards, width: 0): Border.all(color: primary, width: 3) ,

                            boxShadow: [BoxShadow(
                              color: Colors.grey[850]!.withOpacity(0.29),
                              offset: const Offset(-5, 5),
                              blurRadius: 10,
                              spreadRadius: 2
                            )],
                            image: const DecorationImage(
                                image: AssetImage('assets/images/tarjeta_carro.png'),
                              fit: BoxFit.cover
                            )
                          ),
                        ),
                        Visibility(
                          visible: isVisibleCheckCarro,
                          child: Image(
                              height: 45.r,
                              width: 45.r,
                              image: const AssetImage('assets/images/check_verde.png')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          _controller.guardarTipoServicio('Moto');
                          if (mounted) {
                            setState(() {
                              isVisibleCheckCarro = false;
                              isVisibleCheckEncomienda = false;
                              isVisibleCheckMoto = true;
                            });
                          }

                        },
                        child: Container(
                          margin: EdgeInsets.all(15.r),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5.r)),
                          height: !isVisibleCheckMoto?  ScreenUtil().setSp(45.r) : ScreenUtil().setSp(65.r),
                          width:  !isVisibleCheckMoto?  ScreenUtil().setSp(75.r) : ScreenUtil().setSp(115.r),
                          decoration: BoxDecoration(
                              color: blanco,
                              borderRadius: const BorderRadius.all(Radius.circular(12),
                              ),
                              border:  !isVisibleCheckMoto? Border.all(color: blancoCards, width: 0): Border.all(color: primary, width: 3) ,
                              boxShadow: [BoxShadow(
                                  color: Colors.grey[850]!.withOpacity(0.29),
                                  offset: const Offset(-5, 5),
                                  blurRadius: 10,
                                  spreadRadius: 2
                              )],
                              image: const DecorationImage(
                                  image: AssetImage('assets/images/tarjeta_moto.png'),
                                  fit: BoxFit.cover
                              )
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isVisibleCheckMoto,
                        child: Image(
                            height: 45.r,
                            width: 45.r,
                            image: const AssetImage('assets/images/check_verde.png')),
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          _controller.guardarTipoServicio('Encomienda');
                          if (mounted) {
                            setState(() {
                              isVisibleCheckCarro = false;
                              isVisibleCheckMoto = false;
                              if (_aceptoTerminos == false){
                                isVisibleTarjetaEncomiendas= true;
                              }
                              isVisibleCheckEncomienda = true;
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(15.r),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5.r)),
                          height: !isVisibleCheckEncomienda? ScreenUtil().setSp(45.r) : ScreenUtil().setSp(65.r),
                          width:  !isVisibleCheckEncomienda?  ScreenUtil().setSp(75.r) : ScreenUtil().setSp(115.r),
                          decoration: BoxDecoration(
                              color: blanco,
                              borderRadius: const BorderRadius.all(Radius.circular(12)
                              ),
                              border:  !isVisibleCheckEncomienda? Border.all(color: blancoCards, width: 0): Border.all(color: primary, width: 3) ,
                              boxShadow: [BoxShadow(
                                  color: Colors.grey[850]!.withOpacity(0.29),
                                  offset: const Offset(-5, 5),
                                  blurRadius: 10,
                                  spreadRadius: 2
                              )],
                              image: const DecorationImage(
                                  image: AssetImage('assets/images/tarjeta_encomienda.png'),
                                  fit: BoxFit.cover
                              )
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isVisibleCheckEncomienda,
                        child: Image(
                            height: 45.r,
                            width: 45.r,
                            image: const AssetImage('assets/images/check_verde.png')),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
          _textapuntes (),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5.r),
            margin: EdgeInsets.only(top: 15.r, left: 10.r, right: 10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: blanco, // Cambia el color de fondo del contenedor a blanco
            ),
            child: Text(_con.text.isNotEmpty ? _con.text : 'Sin apuntes', style: TextStyle(
             fontSize: 16.r, color: Colors.redAccent, fontWeight: FontWeight.w900
            ),
            maxLines: 2),
          ),

          Expanded(
            child: Container(
            ),
          ),
          Container(
            width: double.infinity,
            height: 48.r,
            margin: EdgeInsets.only(left: 25.r, right: 25.r, bottom: 30.r),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () async {
                bool hasConnection = await connectionService.hasInternetConnection();

                if (hasConnection) {
                  // Si hay conexión, ejecuta la acción de ir a "Olvidaste tu contraseña"
                  verificarCedulaInicial();
                } else {
                  // Si no hay conexión, muestra un AlertDialog
                  alertSinInternet();
                }


              },
              icon: Icon(Icons.check_circle, size: 30.r, color: blanco,),
              label: Text(
                'Confirmar Viaje',
                style: TextStyle(color: blanco, fontSize: 20.r, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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

  Widget _textapuntes (){
    return GestureDetector(
      onTap: (){
        if (mounted) {
          setState(() {
            isVisibleCajonApuntesAlConductor = true;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.double_arrow, size: 20.r, color: negro),
            Text('Apuntes al conductor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.r, color: negro )),
          ],
        ),
      ),
    );
  }

  Widget _apuntesAlConductor() {
    return Visibility(
      visible: isVisibleCajonApuntesAlConductor,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          height: MediaQuery.of(context).size.height * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: blanco,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: gris,
                offset: Offset(3, -2),
                blurRadius: 10,
              )
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Verifica si tipoServicio es "Encomienda" para mostrar esta sección
                if (_controller.tipoServicio == "Encomienda") ...[
                  Column(
                    children: [
                      Text(
                        'ENCOMIENDA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18.r,
                          color: negro,
                        ),
                      ),
                      Image.asset(
                        'assets/images/encomiendas.png',
                        width: 100.r,
                        height: 100.r,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.r),
                ],
                Text(
                  _controller.tipoServicio == "Encomienda"
                      ? 'Describe de manera clara en qué consiste tu encomienda.'
                      : 'Escribe al conductor alguna información importante para tu viaje.',
                  style: TextStyle(
                    fontSize: 16.r,
                    color: negro,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 30.r),
                TextField(
                  maxLength: 80,
                  autofocus: true,
                  showCursor: true,
                  controller: _con,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: primary, // Cambia el color del cursor
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary), // Línea inferior azul cuando no está enfocado
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary), // Línea inferior verde cuando está enfocado
                    ),
                  ),
                ),
                SizedBox(height: 35.r),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        elevation: 6, // Elevación del botón
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            isVisibleCajonApuntesAlConductor = false;
                          });
                        }
                        _obtenerApuntesAlConductor();
                        _controller.guardarApuntesConductor(apuntesAlConductor!);
                      },
                      child: Row(
                        children: [
                          Text(
                            'Guardar',
                            style: TextStyle(
                              color: blanco,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.r,
                            ),
                          ),
                          SizedBox(width: 10.r),
                          Icon(
                            Icons.touch_app_outlined,
                            size: 16.r,
                            color: blanco,
                          ),
                        ],
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


  void _obtenerApuntesAlConductor(){
    apuntesAlConductor = _con.text;
  }

  void verificarCedulaInicial() {
    String? fotoDelantera = _controller.client?.the13FotoCedulaDelantera;
    String? fotoTrasera = _controller.client?.the14FotoCedulaTrasera;

    if (fotoDelantera == "" || fotoTrasera == "") {
      Navigator.pushNamed(context, 'info_seguridad_page');
    } else {
      // Primero validamos si es "Encomienda" y si los apuntes están vacíos
      if (_controller.tipoServicio == "Encomienda") {
        if (_controller.apuntesAlConductor?.isEmpty ?? true) {
          // Mostrar el cajón de apuntes al conductor solo si está vacío
          setState(() {
            isVisibleCajonApuntesAlConductor = true;
          });
          return; // Aquí detenemos la ejecución de cualquier otra lógica
        }
      }

      // El resto del código solo se ejecuta si los apuntes no están vacíos
      if (mounted) { // Verifica si el widget está montado
        setState(() {
          isVisibleTarjetaSolicitandoConductor = true;
        });
      }

      _startSearch();
      _controller.createTravelInfo();

      // Validación del tipo de servicio para llamar al método adecuado
      if (_controller.tipoServicio == "Encomienda") {
        // Enviar notificación al conductor y motociclista más cercano
        _controller.getNearbyEncomiendas();

      } else if (_controller.tipoServicio == "Transporte") {
        // Solo enviar notificación al conductor más cercano
        _controller.getNearbyDrivers();
      } else if (_controller.tipoServicio == "Moto") {
        // Solo enviar notificación al motociclista más cercano
        _controller.getNearbyMotorcyclers();
      }
    }
  }


  Widget _tarjetaInfoEncomienda(){
    if (!mounted) {
      return Container(); // Retorna un widget vacío si el widget ya no está montado
    }
    return Visibility(
      visible: isVisibleTarjetaEncomiendas,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        width: double.infinity,
        height: double.maxFinite,
        padding: EdgeInsets.all(25.r),
        child:  Container(
          margin: EdgeInsets.only(top: 50.r),
          padding: EdgeInsets.all(20.r),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: blanco,
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Encomiendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.r, color: negro)),
                SizedBox(height: 30.r),
                Text('Nuestro servicio de encomiendas está diseñado para proporcionar un envío rápido '
                    'y eficiente de artículos pequeños, tales como cajas, maletas, paquetes y documentos. '
                    'Nos aseguramos de que el volumen de los objetos no supere la capacidad del maletero del '
                    'vehículo y que el peso no exceda los 90 kilos. Queremos garantizar la entrega segura y oportuna '
                    'de tus pertenencias, brindándote la tranquilidad de que tu encomienda será manejada '
                    'con cuidado y responsabilidad.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                  color: gris, fontWeight: FontWeight.w400, fontSize: 12.r,)
                ),
                SizedBox(height: 10.r),
                Text(' Es importante destacar que no está permitido el envío de dinero, joyas, títulos valores '
                    'u objetos similares. Además, queda prohibido el transporte de sustancias químicas corrosivas o '
                    'con cualquier característica que pueda poner en riesgo la integridad del conductor o del envío.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: gris, fontWeight: FontWeight.w400, fontSize: 12.r,)
                ),
                SizedBox(height: 10.r),
              Row(
                children: [
                  Checkbox(
                    activeColor: primary,
                    value: _isChecked,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        }
                      },
                      child: GestureDetector(
                        onTap: (){},
                        child: Text(
                          'Acepto los Términos y Condiciones',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: primary,
                            fontSize: 12.r,
                            decorationColor: primary
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                SizedBox(height: 20.r),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  onPressed: () async {
                    if (_isChecked) {
                      await _guardarAceptoTerminos();
                      if (mounted) {
                        setState(() {
                          isVisibleTarjetaEncomiendas= false;
                        });
                      }
                    } else {
                      await _mostrarAlerta();
                    }
                  },
                    child: const Text('Aceptar', style: TextStyle(color: blanco),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaSolicitandoConductor() {
    if (!mounted) {
      return Container(); // Retorna un widget vacío si el widget ya no está montado
    }
    _controller.obtenerTipoServicio();
    return Visibility(
      visible: isVisibleTarjetaSolicitandoConductor,
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 50.r, left: 30.r, right: 30.r),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          color: blancoCards,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            SizedBox(height: 10.r),
            _getSearchingImage(),
            Text(
              _getSearchingText(), // Usar función para obtener el texto según tipoServicio
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.r, color: negro),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.r),
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isSearching)
                  SpinKitRipple(
                    color: primary,
                    size: 200.r,
                  ),
                Image.asset(
                  'assets/images/logo_zafiro-pequeño.png',
                  width: 60.r,
                  height: 60.r,
                ),

              ],
            ),
            Text(
              'Esperando respuesta...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.r, color: negro),
            ),
            SizedBox(height: 50.r),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isVisibleTarjetaSolicitandoConductor = false;
                    _isSearching = false;
                  });
                }
                _controller.deleteTravelInfo();
              },
              icon: const Icon(Icons.cancel, color: blanco),
              label: Text('Cancelar el Viaje', style: TextStyle(color: blanco, fontSize: 16.r)),
            ),

          ],
        ),
      ),
    );
  }


  // Función para obtener el texto de búsqueda según tipoServicio
  String _getSearchingText() {
    switch (_controller.tipoServicio) {
      case "Transporte":
        return 'Buscando Automoviles disponibles';
      case "Moto":
        return 'Buscando Motociclistas disponibles';
      case "Encomienda":
        return 'Buscando quién entregue tu Encomienda';
      default:
        return 'Buscando conductores disponibles';
    }
  }

  Widget _getSearchingImage() {
    String imagePath;
    switch (_controller.tipoServicio) {
      case "Transporte":
        imagePath = 'assets/images/carro_plateado.png';
        break;
      case "Moto":
        imagePath = 'assets/images/moto_conductor.png';
        break;
      case "Encomienda":
        imagePath = 'assets/images/encomiendas.png';
        break;
      default:
        imagePath = 'assets/images/check_verde.png'; // Imagen por defecto si no coincide ninguno
        break;
    }

    return Image.asset(
      imagePath,
      width: 180.r, // Ajusta el ancho de la imagen según sea necesario
      height: 110.r, // Ajusta la altura de la imagen según sea necesario
    );
  }
  void _startSearch() {
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }
  }

}
