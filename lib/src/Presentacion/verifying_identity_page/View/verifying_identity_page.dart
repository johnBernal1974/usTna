import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../../../../providers/auth_provider.dart';
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
      updateVerifyStatus();
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent)

    );
    return  Scaffold(
      body:
      Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomLeft,
                    colors: [
                      blanco,blanco, blanco,blanco, blanco, blanco,blanco, turquesa, turquesa, turquesa, negro,
                    ])
            ),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 90.0),
              child: Container(
                decoration:  BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter, colors: [
                      negro.withOpacity(0.0),
                      negro.withOpacity(0.3)
                    ] )
                ),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 20, right: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    alignment: Alignment.centerRight,
                    child: const Image(
                        height: 60.0,
                        width: double.infinity,
                        image: AssetImage('assets/images/logo_tayrona_solo.png')),
                  ),

                  Container(
                    padding: const EdgeInsets.all(25),
                    child: headerText(
                        text: 'Proceso de verificación \nde identidad',
                        fontSize: 20,
                        color: negro,
                        fontWeight: FontWeight.w800
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: const Image(
                        width: 280.0,
                        image: AssetImage('assets/images/verify_identity.png')),
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    child: headerText(
                        text: 'Tay-rona ofrece una plataforma que busca dar más seguridad tanto para conductores como usuarios, por ello, en este momento nuestro equipo está realizando la validación de tu identidad.',
                        fontSize: 12,
                        color: negroLetras,
                        fontWeight: FontWeight.w400,
                        textAling: TextAlign.center
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    child: headerText(
                        text: 'Dentro de poco recibirás la notificación de la activación de tu cuenta.',
                        fontSize: 14,
                        color: negro,
                        fontWeight: FontWeight.w600,
                        textAling: TextAlign.center
                    ),
                  ),

                  _botonCerrar()

                ],
              ),
            ),
          ),
        ],

      ),

    );
  }

  void updateVerifyStatus() async {
    String? verificationStatus;
    client = await _clientProvider.getById(_authProvider.getUser()!.uid);
    verificationStatus = client?.verificacionStatus;
    print("ESTATUS AL INGRESAL A LA PAGINA******************************$verificationStatus");
    if(verificationStatus != "corregida"){
      Map<String, dynamic> data = {
        'Verificacion_Status': 'Procesando'
      };
      await _clientProvider.update(data, _authProvider.getUser()!.uid);
      print("ESTATUS LUEGO DE LA VALIDACION******************************$verificationStatus");
    }
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
}
