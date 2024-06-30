
import 'package:flutter/material.dart';
import '../../../Helpers/alert_dialog.dart';
import '../../../providers/AuthService.dart';
import '../../colors/colors.dart';
import '../commons_widgets/Buttons/rounded_button.dart';
import '../commons_widgets/headers/header_text/header_text.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final TextEditingController _emailController = TextEditingController();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: primary, size: 30),
        title: headerText(
          text: "",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: negro,
        ),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 100.0,
              image: AssetImage('assets/images/logo_tayrona_solo.png'))
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                child: const Text(
                  '¿Olvidaste\ntu contraseña?',
                  style: TextStyle(
                    color: negro,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              headerText(
                text:
                'Ingresa el correo electrónico del cual quieres restablecer la contraseña',
                color: gris,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 60),
              _emailImput(),
              const SizedBox(height: 25),
              _botonEnviar()
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailImput() {
    return TextField(
      controller: _emailController,
      style: const TextStyle(
          color: negroLetras, fontSize: 15, fontWeight: FontWeight.w500),
      keyboardType: TextInputType.emailAddress,
      cursorColor: const Color.fromARGB(255, 5, 158, 187),
      decoration: const InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, size: 20, color: primary),
            Text(
              '  Correo electrónico',
              style: TextStyle(color: primary, fontSize: 17, fontWeight: FontWeight.w400),
            )
          ],
        ),
        prefixIconColor: primary,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: grisMedio, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  Widget _botonEnviar(){
    return createElevatedButton(context: context,
        labelButton: 'Restablecer',
        labelFontSize: 20,
        color: primary,
        icon: null,
        func: () async {
          String email= _emailController.text;
          try {
            // Llama al método de restablecimiento de contraseña
            await AuthService().resetPassword(email);
            // Muestra un mensaje de éxito
            mostrarAlertDialog(context, 'Link Enviado', 'Se ha enviado un link de restablecimiento de contraseña al correo: $email', () => null, 'Cerrar');



          } catch (e) {
            // Muestra un mensaje de error al usuario
            print('Error al restablecer la contraseña: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$e'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
    });
  }

  void mostrarLinkEnviadoDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Link Enviado'),
          content: Text(
              'Se ha enviado un link de restablecimiento de contraseña al correo: $email'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
