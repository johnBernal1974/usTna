import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../colors/colors.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isEmailVerified = false;
  bool _isSendingVerification = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _checkEmailVerification().then((isVerified) {
      if (!isVerified) {
        _sendVerificationEmail(); // Enviar correo de verificación automáticamente si aún no está verificado
      }
    });
  }

  // Verificar si el correo ya ha sido verificado
  Future<bool> _checkEmailVerification() async {
    await _currentUser?.reload();
    final isVerified = _currentUser?.emailVerified ?? false;
    setState(() {
      _isEmailVerified = isVerified;
    });
    if (_isEmailVerified) {
      if(context.mounted){
        Navigator.pushReplacementNamed(context, 'map_client');
      }
    }
    return isVerified;
  }

  // Enviar correo de verificación
  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isSendingVerification = true;
    });
    await _currentUser?.sendEmailVerification();
    setState(() {
      _isSendingVerification = false;
    });

    if(context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Correo de verificación enviado. Revisa tu bandeja de entrada.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmación de Correo'),

      ),
      body: Center(
        child: _isEmailVerified
            ? const CircularProgressIndicator()
            : Container(
          margin: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
              Image.asset(
                'assets/images/email_enviado.png',
                height: 70,
                width: 70,
              ),
              const SizedBox(height: 30),
              const Text(
                'Hemos enviado el link de confirmación al correo:',
                style: TextStyle(fontSize: 14), // Tamaño de fuente reducido
                textAlign: TextAlign.center,
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              const Text(
                'Es indispensable que verifiques tu email para poder ingresar a la aplicación',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Tamaño de fuente reducido
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 20),
              const Text(
                '¿No recibiste el correo?',
                style: TextStyle(fontSize: 16, color: negro, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
               onPressed: _isSendingVerification ? null : _sendVerificationEmail,
               style: ButtonStyle(
               backgroundColor: MaterialStateProperty.all(primary), // Fondo color primary
               foregroundColor: MaterialStateProperty.all(Colors.white), // Texto color blanco
               ),
               child: _isSendingVerification
                ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Indicador de progreso en blanco
                )
                : const Text('Reenviar Correo de Verificación'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'splash');
                  },
                  child: const Text(
                    'Ya verifiqué mi correo',
                    style: TextStyle(color: gris),
                  ),
                ),

              ],
          ),
        ),
      ),
    );
  }
}
