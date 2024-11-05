
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:zafiro_cliente/src/models/client.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';


class VerifyingIdentityPage extends StatefulWidget {
  const VerifyingIdentityPage({super.key});

  @override
  State<VerifyingIdentityPage> createState() => _VerifyingIdentityPageState();
}

class _VerifyingIdentityPageState extends State<VerifyingIdentityPage> {

  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  Client? client;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _authProvider = MyAuthProvider();
      _clientProvider = ClientProvider();

      if (_authProvider.getUser() != null) {
        updateStatusProcesando();
      } else {
        if (kDebugMode) {
          print("Error: Usuario no autenticado.");
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
         Container(
            margin: const EdgeInsets.only(top: 20, right: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    alignment: Alignment.centerRight,
                    child: const Column(
                      children: [
                        Image(
                          height: 60.0,
                          width: double.infinity,
                          image: AssetImage('assets/images/imagen_zafiro_azul.png'),
                        ),
                        Image(
                          height: 60.0,
                          width: double.infinity,
                          image: AssetImage('assets/images/logo_zafiro-pequeño.png'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Proceso de verificación \nde identidad',
                      style: TextStyle(
                        fontSize: 20,
                        color: negro,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: const Image(
                      width: 200.0,
                      image: AssetImage('assets/images/verify_identity.png'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    child: headerText(
                      text:
                      'Zafiro ofrece una plataforma que busca dar más seguridad tanto para conductores como usuarios, por ello, en este momento nuestro equipo está realizando la validación de tu identidad.',
                      fontSize: 12,
                      color: negroLetras,
                      fontWeight: FontWeight.w400,
                      textAling: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    child: headerText(
                      text:
                      'Dentro de poco recibirás la notificación de la activación de tu cuenta.',
                      fontSize: 14,
                      color: negro,
                      fontWeight: FontWeight.w600,
                      textAling: TextAlign.center,
                    ),
                  ),
                  _botonCerrar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _botonCerrar() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(top: 25),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, "splash", (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Color del botón
        ),
        child: const Text(
          'Cerrar',
          style: TextStyle(fontSize: 16, color: blanco),
        ),
      ),
    );
  }

  void updateStatusProcesando() async {
    String? userId = _authProvider.getUser()?.uid;
    if (userId != null) {

      Client? client = await _clientProvider.getById(userId);
      if (client != null) {
        Map<String, dynamic> data = {
          'Verificacion_Status': "Procesando",
        };
        await _clientProvider.update(data, userId);
      } else {
        if (kDebugMode) {
          print("Error: No se encontró el cliente para el ID $userId");
        }
      }
    } else {
      if (kDebugMode) {
        print("Error: Usuario no autenticado o ID inválido.");
      }
    }
  }

}
