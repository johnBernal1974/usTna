import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class CompartirAplicacionpage extends StatefulWidget {
  const CompartirAplicacionpage({super.key});

  @override
  State<CompartirAplicacionpage> createState() => _CompartirAplicacionpageState();
}

class _CompartirAplicacionpageState extends State<CompartirAplicacionpage> {
  Future<String?> _getLinkFromFirestore(String field) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Prices')
          .doc('info')
          .get();
      return snapshot[field] as String?;
    } catch (e) {
      if (kDebugMode) {
        print("Error obteniendo el enlace de Firestore: $e");
      }
      return null;
    }
  }

  void _shareAppLinkViaWhatsAppDriver(BuildContext context, String link) async {
    String message = "¡Ingresando a este enlace podrás descargar Zafiro Conductor! $link";
    final Uri uri = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        _showNoWhatsAppInstalledDialog(context);
      }
    }
  }

  void _shareAppLinkViaWhatsAppClient(BuildContext context, String link) async {
    String message = "¡Ingresando a este enlace podrás descargar Zafiro Cliente! $link";
    final Uri uri = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        _showNoWhatsAppInstalledDialog(context);
      }
    }
  }

  void _showNoWhatsAppInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'WhatsApp no instalado',
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'No tienes WhatsApp en tu dispositivo. Instálalo e intenta de nuevo',
            style: TextStyle(fontSize: 14.r),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: negro, fontWeight: FontWeight.w900, fontSize: 14.r),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      backgroundColor: blancoCards,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: IconThemeData(color: negro, size: 26.r),
        title: headerText(
          text: "Compartir aplicación",
          fontSize: 20.r,
          fontWeight: FontWeight.w700,
          color: negro,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Opción 1',
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800),
            ),
            headerText(
              text: 'Comparte Zafiro con tus amigos, familiares y personas queridas mediante WhatsApp dando click en alguno de los sigientes iconos:',
              fontSize: 14.r,
              fontWeight: FontWeight.w500,
              color: negro,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    String? linkClient = await _getLinkFromFirestore('link_descarga_client');
                    if (linkClient != null) {
                      if (context.mounted) {
                        _shareAppLinkViaWhatsAppClient(context, linkClient);
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15.r, top: 15.r, right: 15.r),
                            child: Image(
                              height: 50.r,
                              width: 50.r,
                              image: const AssetImage('assets/images/logo_compartir_zafiro.png'),
                            ),
                          ),
                          const Image(
                            height: 35.0,
                            width: 35.0,
                            image: AssetImage('assets/images/icono_compartir_circular.png'),
                          ),
                        ],
                      ),
                      headerText(
                        text: 'Cliente',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: negroLetras,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String? linkDriver = await _getLinkFromFirestore('link_descarga_driver');
                    if (linkDriver != null) {
                      if (context.mounted) {
                        _shareAppLinkViaWhatsAppDriver(context, linkDriver);
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15.r, top: 15.r, right: 15.r),
                            child: Image(
                              height: 50.r,
                              width: 50.r,
                              image: const AssetImage('assets/images/logo_compartir_zafiro_conductor2.png'),
                            ),
                          ),
                          Image(
                            height: 35.r,
                            width: 35.r,
                            image: const AssetImage('assets/images/icono_compartir_circular.png'),
                          ),
                        ],
                      ),
                      headerText(
                        text: 'Conductor',
                        fontSize: 12.r,
                        fontWeight: FontWeight.w700,
                        color: negroLetras,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: grisMedio),
            const SizedBox(height: 30),
            Text(
              'Opción 2',
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800),
            ),
            Text(
              'Dile que escanee el código QR de la app que quiere instalar',
              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  qrDriver(),
                  const SizedBox(width: 30), // Espacio entre las imágenes
                  qrCliente(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.r),
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: index == 0 ? negroLetras : grisMedio, // Punto activo y pasivo
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget qrDriver() {
    return Image(
      height: 320.r,
      width: 320.r,
      image: const AssetImage('assets/images/qr_zafiro_conductor.png'),
    );
  }

  Widget qrCliente() {
    return Image(
      height: 320.r,
      width: 320.r,
      image: const AssetImage('assets/images/qr_zafiro_cliente.png'),
    );
  }
}
