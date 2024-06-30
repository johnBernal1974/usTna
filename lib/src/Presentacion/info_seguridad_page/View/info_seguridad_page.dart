import 'package:flutter/material.dart';
import 'package:tayrona_usuario/providers/auth_provider.dart';
import 'package:tayrona_usuario/src/colors/colors.dart';

class InfoSeguridadPage extends StatefulWidget {
  const InfoSeguridadPage({super.key});

  @override
  State<InfoSeguridadPage> createState() => _InfoSeguridadPageState();
}

class _InfoSeguridadPageState extends State<InfoSeguridadPage> {
  final MyAuthProvider _authProvider = MyAuthProvider();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _tituloSeguridad(),
                const SizedBox(height: 25),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.all(5),
                      height: 105,
                      width: 175,
                      decoration: BoxDecoration(
                          color: blanco,
                          borderRadius: const BorderRadius.all(Radius.circular(12),
                          ),
                          border: Border.all(color: gris, width: 1),
                          boxShadow: [BoxShadow(
                              color: Colors.grey[850]!.withOpacity(0.29),
                              offset: const Offset(-5, 5),
                              blurRadius: 10,
                              spreadRadius: 2
                          )],
                          image: const DecorationImage(
                              image: AssetImage('assets/images/documento_frente.png'),
                              fit: BoxFit.cover
                          )
                      ),
                    ),

                    const Image(
                        height: 59.0,
                        width: 59.0,
                        image: AssetImage('assets/images/check_verde.png'),
                        ),
                  ],
                ),

                const SizedBox(height: 30),
                _textoContenido(),
                const SizedBox(height: 20),
                _textoContenido2(),
                const SizedBox(height: 20),
                _textoContenido3(),
                const SizedBox(height: 20),
                _botonAceptar()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tituloSeguridad(){
    return const Text('¡Velamos por tu seguridad!', style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,);
  }

  Widget _textoContenido(){
    return const Text('Nuestra principal prioridad es garantizar '
        'la seguridad y el bienestar de todos los miembros de '
        'nuestra comunidad. Como parte de nuestros esfuerzos continuos '
        'para mantener un entorno seguro y confiable, implementamos '
        'un proceso de verificación de identidad para todos nuestros usuarios.', style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: negroLetras,
    ),
      textAlign: TextAlign.justify,);
  }

  Widget _textoContenido2(){
    return const Text('La verificación de identidad ayuda a prevenir el uso fraudulento de la plataforma, protegiendo así a todos los usuarios.', style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: negroLetras,
    ),
      textAlign: TextAlign.justify,);
  }

  Widget _textoContenido3(){
    return const Text('Para continuar, da click en el botón aceptar y carga tu documento de identidad.', style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: negroLetras,
    ),
      textAlign: TextAlign.justify,);
  }

  Widget _botonAceptar() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: ElevatedButton(
        onPressed: () {

          _authProvider.verificarFotosCedulaDelantera(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Color del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: blanco,), // Icono de cámara
            SizedBox(width: 8), // Espacio entre el icono y el texto
            Text(
              'Aceptar',
              style: TextStyle(fontSize: 16, color: blanco),
            ),
          ],
        ),
      ),
    );
  }
}
