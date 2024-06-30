
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';

class PaginaDeBloqueo extends StatefulWidget {

  @override
  State<PaginaDeBloqueo> createState() => _PaginaDeBloqueoState();
}


class _PaginaDeBloqueoState extends State<PaginaDeBloqueo> {

  late MyAuthProvider _authProvider;
  late ClientProvider  _clientProvider ;

  @override
  void initState() {
    super.initState();
    _authProvider = MyAuthProvider();
    _clientProvider = ClientProvider();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent)

    );
    return  Scaffold(
      backgroundColor: blancoCards,
      body:
          Container(
            margin: const EdgeInsets.only(top: 20, right: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    alignment: Alignment.centerRight,
                    child: const Image(
                        height: 50.0,
                        width: double.infinity,
                        image: AssetImage('assets/images/logo_tayrona_solo.png')),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                    child: Column(
                      children: [
                        headerText(
                            text: 'Tu usuario se encuentra temporalmente',
                            fontSize: 16,
                            color: negroLetras,
                            fontWeight: FontWeight.w400
                        ),
                        headerText(
                            text: 'SUSPENDIDO',
                            fontSize: 20,
                            color: negro,
                            fontWeight: FontWeight.w900
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Icon(Icons.block, color: Colors.red.shade900, size: 100)),

                  Container(
                    margin: const EdgeInsets.only(left: 40, right: 40),
                    padding: const EdgeInsets.all(10),
                    child: headerText(
                        text: 'Si deseas tener más detalles al respecto comunicate con nosotros por cualquiera de nuestros canales de información.',
                        fontSize: 14,
                        color: negroLetras,
                        fontWeight: FontWeight.w400,
                        textAling: TextAlign.justify
                    ),
                  ),
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
                ],
              ),
            ),
          ),


    );
  }

  void _openWhatsApp(BuildContext context) async {
    String userId = _authProvider.getUser()!.uid;

    // Obtener el conductor actualizado
    Client? _client = await _clientProvider.getById(userId);
    const phoneNumber = '+573108101723';
    String? name = _client?.the01Nombres;
    String? apellidos = _client?.the02Apellidos;
    String message = 'Mi nombre es ${name} ${apellidos}. Requiero saber el motivo del bloqueo de mi cuenta.';
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