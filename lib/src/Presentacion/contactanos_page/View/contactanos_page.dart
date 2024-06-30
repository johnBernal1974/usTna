import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../contactanos_controller/contactanos_controller.dart';


class ContactanosPage extends StatefulWidget {
  const ContactanosPage({super.key});

  @override
  State<ContactanosPage> createState() => _ContactanosPageState();
}

class _ContactanosPageState extends State<ContactanosPage> {

  late ContactanosController _controller;

  @override
  void initState() {
    _controller = ContactanosController(); // Inicializar _controller aquí
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Llama al método dispose del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "Contáctanos",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: negro
        ),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 60.0,
              image: AssetImage('assets/images/imagen_mujer_call_us.png'))

        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 25),
            alignment: Alignment.center,
            child: Column(
              children: [
                headerText(
                    text: '¿En que te podemos ayudar?',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  color: negroLetras
                ),

                const Image(
                    height: 130.0,
                    width: 130.0,
                    image: AssetImage('assets/images/imagen_mujer_call_us.png')),

                Container(
                  margin: const EdgeInsets.only(left: 50, right: 50, top: 25,bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                              onPressed: (){
                                makePhoneCall('3108101723');
                              },
                              icon: const Icon(Icons.phone),
                          iconSize: 30,),

                          headerText(
                              text: "Llámanos",
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: negroLetras
                          ),
                        ],
                      ),


                      Column(
                        children: [
                          IconButton(
                            onPressed: (){
                              _openWhatsApp(context);
                            },
                            icon: Image.asset('assets/images/icono_whatsapp.png',
                            width: 30,
                            height: 30),
                           ),

                          headerText(
                              text: "Chatea",
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: negroLetras
                          ),
                        ],
                      )
                    ],
                  ),

                ),

                const Divider(height: 2, color: grisMedio,endIndent: 25, indent: 25),

                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: headerText(
                    text: "Canales de comunicación\n24 horas",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: negroLetras),
                )
              ],

            )),
      ),
    );

  }

  void _openWhatsApp(BuildContext context) async {
    const phoneNumber = '+573108101723';
    String? name = _controller.client?.the01Nombres.toString();
    String message = 'Hola Tay-rona, mi nombre es $name y requiero de su asistencia.';

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
