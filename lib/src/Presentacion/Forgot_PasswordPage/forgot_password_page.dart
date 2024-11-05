import 'dart:async';
import 'package:flutter/material.dart';
import '../../../Helpers/alert_dialog.dart';
import '../../../providers/AuthService.dart';
import '../../../providers/conectivity_service.dart';
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
  final AuthService authService = AuthService();
  final ConnectionService _connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
          text: "",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: negro,
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: const Image(
              width: 80.0,
              image: AssetImage('assets/images/logo_zafiro-pequeño.png'),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitle(),
              _buildSubtitle(),
              const SizedBox(height: 60),
              _buildEmailInput(),
              const SizedBox(height: 25),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
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
    );
  }

  Widget _buildSubtitle() {
    return headerText(
      text: 'Ingresa el correo electrónico del cual quieres restablecer la contraseña',
      color: gris,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildEmailInput() {
    return TextField(
      controller: _emailController,
      style: const TextStyle(
        color: negroLetras,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
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
            ),
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

  Widget _buildSendButton() {
    return createElevatedButton(
      context: context,
      labelButton: 'Restablecer',
      labelFontSize: 20,
      color: primary,
      icon: null,
      func: () async {
        // Verificar conexión a Internet antes de ejecutar la acción
        bool hasConnection = await _connectionService.hasInternetConnection();
        if (!hasConnection) {
          await alertSinInternet(); // Llama al AlertDialog si no hay conexión
          return; // Termina la ejecución si no hay conexión
        }
        final email = _emailController.text.trim(); // Eliminar espacios adicionales
        // Verificar si el campo de email está vacío
        if (email.isEmpty) {
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, ingresa un correo electrónico.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return; // Termina la ejecución si el campo está vacío
        }
        // Expresión regular para validar el formato del correo electrónico
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(email)) {
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, ingresa un correo electrónico válido.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return; // Termina la ejecución si el correo no es válido
        }
        try {
          await AuthService().resetPassword(email);
          if (mounted) {
            mostrarAlertDialog(
              context,
              'Link Enviado',
              'Se ha enviado un link de restablecimiento de contraseña al correo: $email',
                  () => null,
              'Cerrar',
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al restablecer la contraseña: $e'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
    );
  }

  Future alertSinInternet() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sin Internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
