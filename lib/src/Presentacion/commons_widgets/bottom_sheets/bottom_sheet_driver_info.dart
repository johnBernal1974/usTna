
import 'package:flutter/material.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import 'package:tayrona_usuario/src/models/driver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../colors/colors.dart';

class BottomSheetDriverInfo extends StatefulWidget {

  late String imageUrl;
  late String name;
  late String apellido;
  late String calificacion;
  late String numero_viajes;
  late String celular;
  late String placa;
  late String color;
  late String servicio;
  late String marca;


  BottomSheetDriverInfo({
    required this.imageUrl,
    required this.name,
    required this.apellido,
    required this.calificacion,
    required this.numero_viajes,
    required this.celular,
    required this.placa,
    required this.color,
    required this.servicio,
    required this.marca,
});


  @override
  State<BottomSheetDriverInfo> createState() => _BottomSheetDriverInfoState();
}

class _BottomSheetDriverInfoState extends State<BottomSheetDriverInfo> {


  Client? client;
  Driver? driver;
  late DriverProvider _driverProvider;
  late MyAuthProvider _authProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _driverProvider = DriverProvider();
    _authProvider = MyAuthProvider();
    getDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    String placaCompleta =  widget.placa;
    String placaFormateada = '';
    if (placaCompleta.length == 6) {
      String letras = placaCompleta.substring(0, 3);
      String numeros = placaCompleta.substring(3);
      placaFormateada = '$letras-$numeros';
    } else {
      // Manejar el caso en el que la placa no tenga 6 caracteres
      placaFormateada = placaCompleta; // O asignar un valor por defecto
    }
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width, // Ancho del contenido igual al ancho de la pantalla
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Color de fondo blanco
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: widget.imageUrl != null
                          ? NetworkImage(widget.imageUrl!)
                          : null, // No se proporciona ninguna imagen cuando widget.imageUrl es nulo
                    ),
                  ),

                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20,bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: (){
                                makePhoneCall( widget.celular);
                              },
                              icon: const Icon(Icons.phone),
                              iconSize: 35),
                            const SizedBox(width: 25),
                            IconButton(
                              onPressed: (){
                                _openWhatsApp(context);
                              },
                              icon: Image.asset('assets/images/icono_whatsapp.png',
                                  width: 35,
                                  height: 35),
                            ),

                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la Column
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: negro
                            ),
                          ),
                          Text(
                            widget.apellido,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: primary,
                                    size: 16,
                                  ),

                                ],
                              ),
                              Text(
                                widget.numero_viajes,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 30),
                          Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: primary,
                                    size: 16,
                                  ),

                                ],
                              ),
                              Text(
                                widget.calificacion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 10),
              Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: const Divider(height: 2, color: grisMedio)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('Placa', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey), // Color del borde gris
                        ),
                        child: Text(
                          placaFormateada,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Marca: '),
                          Text(widget.marca, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Color: '),
                          Text(widget.color, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Servicio: '),
                          Text(widget.servicio, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getDriverInfo() async {
    driver = await _driverProvider.getById(_authProvider.getUser()!.uid);
  }


  void _openWhatsApp(BuildContext context) async {
    final phoneNumber = '+57${widget.celular}';
    String? name = driver?.the01Nombres;
    String? nameUser = widget.name;
    String message = 'Hola $nameUser, mi nombre es $name y soy el conductor que aceptó tu solicitud.';

    final whatsappLink = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeQueryComponent(message)}');

    try {
      await launchUrl(whatsappLink);
    } catch (e) {
      showNoWhatsAppInstalledDialog(context);
    }
  }

  void showNoWhatsAppInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp no instalado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          content: const Text('No tienes WhatsApp en tu dispositivo. Instálalo e intenta de nuevo'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar', style: TextStyle(color: negro, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  void makePhoneCall(String phoneNumber) async {
    final phoneCallUrl = 'tel:$phoneNumber';

    try {
      await launch(phoneCallUrl);
    } catch (e) {
      print('No se pudo realizar la llamada: $e');
    }
  }
}
