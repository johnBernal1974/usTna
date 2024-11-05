import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return  Scaffold(
      backgroundColor: blancoCards,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: IconThemeData(color: negro, size: 26.r),
        title: headerText(
            text: "Contáctanos",
            fontSize: 20.r,
            fontWeight: FontWeight.w600,
            color: negro
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 25.r),
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text('¿En qué te\npodemos ayudar?', style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 26.r,
                    color: negro,
                    height: 0.8
                  ),
                  textAlign: TextAlign.center,),
                ),

                Container(
                  margin:EdgeInsets.only(left: 50.r, right: 50.r, top: 25.r,bottom: 30.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                              onPressed: (){
                                makePhoneCall(_controller.whatsappAtencionCliente ?? "");
                              },
                              icon: const Icon(Icons.phone),
                          iconSize: 30.r,),

                          GestureDetector(
                            onTap: () => makePhoneCall(_controller.whatsappAtencionCliente ?? ""),
                            child: headerText(
                                text: "Llamar",
                                fontSize: 12.r,
                                fontWeight: FontWeight.w600,
                                color: negro
                            ),
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
                            width: 30.r,
                            height: 30.r),
                           ),

                          GestureDetector(
                            onTap: () {
                              _openWhatsApp(context);
                            },
                            child: headerText(
                                text: "Chatear",
                                fontSize: 12.r,
                                fontWeight: FontWeight.w600,
                                color: negro
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                ),
                const Divider(height: 2, color: grisMedio,endIndent: 25, indent: 25),
                const SizedBox(height: 50),
                Image.asset('assets/images/imagen_zafiro_azul.png', width: 40.r, height: 40.r),
                Image.asset('assets/images/logo_zafiro-pequeño.png', width: 200.r, height: 70.r),
              ],
            )),
      ),
    );
  }

  void _openWhatsApp(BuildContext context) async {
    String? phoneNumber = _controller.whatsappAtencionCliente;
    String? name = _controller.client?.the01Nombres.toString();
    String message = 'Hola Zafiro, mi nombre es $name y requiero de su asistencia.';

    final whatsappLink = Uri.parse('whatsapp://send?phone=+57$phoneNumber&text=${Uri.encodeQueryComponent(message)}');

    try {
      await launchUrl(whatsappLink);
    } catch (e) {
      if(context.mounted){
        showNoWhatsAppInstalledDialog(context);
      }
    }
  }

  void showNoWhatsAppInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('WhatsApp no instalado', style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800)),
          content: Text('No tienes WhatsApp en tu dispositivo. Instálalo e intenta de nuevo', style: TextStyle(
            fontSize: 14.r
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar', style: TextStyle(color: negro, fontWeight: FontWeight.w900, fontSize: 14.r)),
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
      if (kDebugMode) {
        print('No se pudo realizar la llamada: $e');
      }
    }
  }
}
