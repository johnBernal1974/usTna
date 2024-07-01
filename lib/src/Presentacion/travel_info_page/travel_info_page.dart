import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayrona_usuario/src/Presentacion/travel_info_page/travel_info_Controller/travel_info_Controller.dart';
import 'package:tayrona_usuario/src/colors/colors.dart';
import '../../../Helpers/Validators/FormValidators.dart';
import '../commons_widgets/headers/header_text/header_text.dart';


class ClientTravelInfoPage extends StatefulWidget {
  const ClientTravelInfoPage({super.key});

  @override
  State<ClientTravelInfoPage> createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {

  final TravelInfoController _controller = TravelInfoController();
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
  TextEditingController _con = TextEditingController();
  String? apuntesAlConductor;
  String? tipoServicioSeleccionado;


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
    ScreenUtil.init(context);
    tarifa = _controller.total?.toInt() ?? 0;
    formattedTarifa= FormatUtils.formatCurrency(tarifa!);
    String from = _controller.from ?? "";
    String to = _controller.to ?? "";
    return Scaffold(
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
          // Align(
          //   alignment: Alignment.topLeft,
          //   child: _buttonVolverAtras(),
          // ),
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
          title: const Text('Alerta'),
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
    return Container(
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
          margin: const EdgeInsets.only(right: 10,  left: 10),
          child: Card(
            shape: const CircleBorder(),
            surfaceTintColor: amarilloClaro,
            elevation: 2,
            child: Container(
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.arrow_back, color: negroLetras, size:20,)),

          ),
        ),
      ),
    );
  }

  Widget _cardInfoViaje(String from, String to){
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: double.infinity,
      decoration: const BoxDecoration(
          color: blanco,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30)
          ),
          boxShadow: [BoxShadow(
            color: gris,
            offset: Offset(1,1),
            blurRadius: 10,
          )]
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15, left: 25, right: 25),
            child: Row(
              children: [
                Image.asset('assets/images/posicion_usuario_negra.png', height: 15, width: 15),
                const SizedBox(width: 5),
               Expanded(child: Text(from, maxLines: 1))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            child: Row(
              children: [
                Image.asset('assets/images/posicion_destino.png', height: 15, width: 15),
                const SizedBox(width: 5),
                Expanded(child: Text(to, style: const TextStyle( fontWeight: FontWeight.bold), maxLines: 1))
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
                        headerText(text:'Distancia', fontSize: 10, color: negro, fontWeight: FontWeight.w900),
                        headerText(text: _controller?.km ?? '', fontSize: 10, color: gris, fontWeight: FontWeight.w500),
                      ],
                    ),

                    Column(
                      children: [
                        headerText(text:'Duración', fontSize: 10, color: negro, fontWeight: FontWeight.w900),
                        headerText(text: _controller?.min ?? '', fontSize: 10, color: gris, fontWeight: FontWeight.w500),
                      ],
                    ),
                  ],
                ),

                Container(
                    width: 200,
                    padding: const EdgeInsets.all(10),
                    child: headerText(text: formattedTarifa, fontSize: 26, color: negro, fontWeight: FontWeight.w900)
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
                  //tipoServicio = 'Transporte';
                  _controller.guardarTipoServicio("Transporte");
                  print('Tipo de servicio seleccionado en el boton Trnasporte**************************************$tipoServicio');
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
                          margin: const EdgeInsets.all(15),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5)),
                          height: !isVisibleCheckCarro ? ScreenUtil().setSp(45) : ScreenUtil().setSp(65),
                          width: !isVisibleCheckCarro ? ScreenUtil().setSp(75) : ScreenUtil().setSp(115),
                          decoration: BoxDecoration(
                            color: blanco,
                            borderRadius: const BorderRadius.all(Radius.circular(12),
                            ),
                              border:  !isVisibleCheckCarro? Border.all(color: blancoCards, width: 0): Border.all(color: gris, width: 2) ,

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
                          child: const Image(
                              height: 45.0,
                              width: 45.0,
                              image: AssetImage('assets/images/check_verde.png')),
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
                          //tipoServicio = 'Moto';
                          _controller.guardarTipoServicio('Moto');
                          print('ipo de servicio seleccionado en el boton moto***********************************$tipoServicio');
                          if (mounted) {
                            setState(() {
                              isVisibleCheckCarro = false;
                              isVisibleCheckEncomienda = false;
                              isVisibleCheckMoto = true;
                            });
                          }

                        },
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5)),
                          height: !isVisibleCheckMoto?  ScreenUtil().setSp(45) : ScreenUtil().setSp(65),
                          width:  !isVisibleCheckMoto?  ScreenUtil().setSp(75) : ScreenUtil().setSp(115),
                          decoration: BoxDecoration(
                              color: blanco,
                              borderRadius: const BorderRadius.all(Radius.circular(12),
                              ),
                              border:  !isVisibleCheckMoto? Border.all(color: blancoCards, width: 0): Border.all(color: gris, width: 2) ,
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
                        child: const Image(
                            height: 45.0,
                            width: 45.0,
                            image: AssetImage('assets/images/check_verde.png')),
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
                          //tipoServicio = 'Encomienda';
                          _controller.guardarTipoServicio('Encomienda');
                          print('ipo de servicio seleccionado en el boton Trnasporte**************************$tipoServicio');
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
                          margin: const EdgeInsets.all(15),
                          padding: EdgeInsets.all(ScreenUtil().setSp(5)),
                          height: !isVisibleCheckEncomienda? ScreenUtil().setSp(45) : ScreenUtil().setSp(65),
                          width:  !isVisibleCheckEncomienda?  ScreenUtil().setSp(75) : ScreenUtil().setSp(115),
                          decoration: BoxDecoration(
                              color: blanco,
                              borderRadius: const BorderRadius.all(Radius.circular(12)
                              ),
                              border:  !isVisibleCheckEncomienda? Border.all(color: blancoCards, width: 0): Border.all(color: gris, width: 2) ,
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
                        child: const Image(
                            height: 45.0,
                            width: 45.0,
                            image: AssetImage('assets/images/check_verde.png')),
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
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: blancoCards, // Cambia el color de fondo del contenedor a blanco
            ),
            child: Text(_con.text.isNotEmpty ? _con.text : 'Sin apuntes', style: const TextStyle(
             fontSize: 12
            ),
            maxLines: 2),
          ),

          Expanded(
            child: Container(
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () {
                verificarCedulaInicial();

              },
              icon: const Icon(Icons.check_circle, size: 30, color: blanco,),
              label: const Text(
                'Confirmar Viaje',
                style: TextStyle(color: blanco, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
        margin: const EdgeInsets.only(right: 10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.double_arrow, size: 18, color: negro),
            Text('Apuntes al conductor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _apuntesAlConductor(){
    return Visibility(
      visible: isVisibleCajonApuntesAlConductor,
      child: SingleChildScrollView(
        child: Container(
          height:  MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          decoration: const BoxDecoration(
              color: blanco,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(
                color: gris,
                offset: Offset(3,-2),
                blurRadius: 10,
              )]
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Escribe al conductor alguna información importante para tu viaje.', style: TextStyle(fontSize: 14, color: gris, fontWeight: FontWeight.w400), maxLines: 2,
                ),
                const SizedBox(height: 30),
                TextField(
                  maxLength: 80,
                  autofocus: true,
                  showCursor: true,
                  controller: _con,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor:primary, // Cambia el color del cursor a rojo
                  decoration: const InputDecoration(
                    // Personaliza la apariencia del borde del TextField
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Cambia el color de la línea inferior a azul cuando el TextField no está enfocado
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primary), // Cambia el color de la línea inferior a verde cuando el TextField está enfocado
                    ),
                  ),
                ),

                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: turquesa,
                          elevation: 6// Color del botón
                      ),
                      onPressed:(){
                        if (mounted) {
                          setState(() {
                            isVisibleCajonApuntesAlConductor = false;
                          });
                        }
                        _obtenerApuntesAlConductor();
                        _controller.guardarApuntesConductor(apuntesAlConductor!);
                      },
                      child: const Text('Guardar', style: TextStyle(color: blanco, fontWeight: FontWeight.bold, fontSize: 14)),
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
    print('*********apuntes al conductor******************$apuntesAlConductor');
  }

  void verificarCedulaInicial() {
    String? fotoDelantera = _controller.client?.the13FotoCedulaDelantera;
    print('*********************************** foto delantera $fotoDelantera');
    String? fotoTrasera = _controller.client?.the14FotoCedulaTrasera;
    print('*********************************** foto trasera $fotoTrasera');
    if (fotoDelantera == "" || fotoTrasera == "") {
      print('*********************************** es false');
      Navigator.pushNamed(context, 'info_seguridad_page');
    } else {
      print('*********************************** entro en true');
      if (mounted) { // Verifica si el widget está montado
        setState(() {
          isVisibleTarjetaSolicitandoConductor = true;
        });
      }

      _startSearch();
      _controller.createTravelInfo();
      _controller.seleccionarBusquedaSegunTipoServicio();
      //_controller.getNearbyDrivers();
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
        padding: const EdgeInsets.all(25),
        child:  Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: blanco,
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Encomiendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: negro)),
                const SizedBox(height: 30),
                const Text('Nuestro servicio de encomiendas está diseñado para proporcionar un envío rápido '
                    'y eficiente de artículos pequeños, tales como cajas, maletas, paquetes y documentos. '
                    'Nos aseguramos de que el volumen de los objetos no supere la capacidad del maletero del '
                    'vehículo y que el peso no exceda los 90 kilos. Queremos garantizar la entrega segura y oportuna '
                    'de tus pertenencias, brindándote la tranquilidad de que tu encomienda será manejada '
                    'con cuidado y responsabilidad.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                  color: gris, fontWeight: FontWeight.w400, fontSize: 12,)
                ),
                const SizedBox(height: 10),
                const Text(' Es importante destacar que no está permitido el envío de dinero, joyas, títulos valores '
                    'u objetos similares. Además, queda prohibido el transporte de sustancias químicas corrosivas o '
                    'con cualquier característica que pueda poner en riesgo la integridad del conductor o del envío.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: gris, fontWeight: FontWeight.w400, fontSize: 12,)
                ),
                const SizedBox(height: 10),
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
                        child: const Text(
                          'Acepto los Términos y Condiciones',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: primary,
                            fontSize: 12,
                            decorationColor: primary
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 20),
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
        padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
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

            const SizedBox(height: 10),
            _getSearchingImage(),
            Text(
              _getSearchingText(), // Usar función para obtener el texto según tipoServicio
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: negro),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isSearching)
                  const SpinKitRipple(
                    color: primary,
                    size: 200.0,
                  ),
                Image.asset(
                  'assets/images/logo_tayrona_solo.png',
                  width: 30,
                  height: 30,
                ),

              ],
            ),
            const Text(
              'Esperando respuesta...',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: negro),
            ),
            const SizedBox(height: 50),
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
              label: const Text('Cancelar el Viaje', style: TextStyle(color: blanco)),
            ),
          ],
        ),
      ),
    );
  }

  // Función para obtener el texto de búsqueda según tipoServicio
  String _getSearchingText() {
    switch (_controller.tipoServicioSeleccionado) {
      case "Transporte":
        return 'Buscando AUTOMOBILES disponibles';
      case "Moto":
        return 'Buscando MOTOCICLISTAS disponibles';
      case "Encomienda":
        return 'Buscando quién entregue tu ENCOMIENDA';
      default:
        return 'Buscando conductores disponibles';
    }
  }

  Widget _getSearchingImage() {
    String imagePath;
    switch (_controller.tipoServicioSeleccionado) {
      case "Transporte":
        imagePath = 'assets/images/tarjeta_carro.png';
        break;
      case "Moto":
        imagePath = 'assets/images/tarjeta_moto.png';
        break;
      case "Encomienda":
        imagePath = 'assets/images/tarjeta_encomienda.png';
        break;
      default:
        imagePath = 'assets/images/check_verde.png'; // Imagen por defecto si no coincide ninguno
        break;
    }

    return Image.asset(
      imagePath,
      width: 130, // Ajusta el ancho de la imagen según sea necesario
      height: 130, // Ajusta la altura de la imagen según sea necesario
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
