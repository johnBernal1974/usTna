import 'package:flutter/material.dart';

import '../src/Presentacion/login_page/View/login_page.dart';

Future<void> mostrarAlertDialog(
    BuildContext context,
    String titulo,
    String mensaje,
    Function()? onPressed,
    String textoBotonAceptar) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo, style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(mensaje),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              onPressed?.call();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()));
            },
            child: Text(
              textoBotonAceptar, // Usa el texto proporcionado
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}