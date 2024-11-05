

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zafiro_cliente/src/colors/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/conectivity_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late MyAuthProvider _authProvider;
  final ConnectionService connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
    _authProvider = MyAuthProvider();
    // Verifica la conexión a Internet al iniciar
    _checkConnectionAndAuthenticate();
  }

  void _checkConnectionAndAuthenticate() async {
    // Verifica la conexión y muestra el Snackbar si no hay conexión
    await connectionService.checkConnectionAndShowCard(context, () {
      // Esta función se ejecutará solo si hay conexión y el servicio está disponible
      _authProvider.checkIfUserIsLogged(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      backgroundColor: primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Column(
              children: [
                Image(
                    height: 70.0,
                    width: 70.0,
                    image: AssetImage('assets/images/imagen_zafiro.png')
                ),

                Image(
                    height: 100.0,
                    width: 220.0,
                    image: AssetImage('assets/images/logo_zafiro_splash.png')
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
