
import 'package:flutter/material.dart';
import '../src/colors/colors.dart';

class CustomLoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 100, // Ajusta el ancho y el alto según tus necesidades
            height: 100,
            padding: const EdgeInsets.all(20), // Añade un relleno para que el círculo de progreso no toque los bordes del contenedor
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10), // Agrega bordes redondeados para hacerlo cuadrado
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: grisMedio,
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}