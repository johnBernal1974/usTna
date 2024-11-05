import 'dart:async';
import 'dart:io'; // Para verificar la conexión a Internet
import 'package:flutter/material.dart'; // Para el SnackBar
import 'package:http/http.dart' as http;

class ConnectionService {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false; // Estado para manejar la visibilidad del Card

  // Verificar si hay conexión a Internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Verificar si el servicio está disponible
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Mostrar un Card persistente en la parte superior hasta que se recupere la conexión
  void showPersistentConnectionCard(BuildContext context, VoidCallback onConnectionRestored) {
    if (_isOverlayVisible) return; // Evitar mostrar el Card si ya está visible

    // Crear el OverlayEntry para el Card
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: MediaQuery.of(context).size.width * 0.15, // Ajuste para centrar el Card
        width: MediaQuery.of(context).size.width * 0.7, // Cambia el ancho a 70% del ancho de pantalla
        child: Material(
          color: Colors.transparent,
          child: Card(
            color: Colors.redAccent.shade200,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduce el padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20), // Tamaño del icono más pequeño
                  SizedBox(width: 6), // Reduce el espacio entre icono y texto
                  Text(
                    'Sin Internet.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), // Reduce el tamaño del texto
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insertar el OverlayEntry
    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayVisible = true;

    // Comenzar a verificar la conexión periódicamente
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (await hasInternetConnection()) {
        // Cerrar el Card si la conexión se restableció
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isOverlayVisible = false;
        onConnectionRestored(); // Llama al callback
        timer.cancel(); // Detener el temporizador
      }
    });
  }


  // Método principal para verificar conexión y mostrar el Card si no hay internet
  Future<void> checkConnectionAndShowCard(BuildContext context, VoidCallback onConnectionRestored) async {
    if (await hasInternetConnection()) {
      // Verificar si el servicio está disponible solo si hay conexión
      if (await isServiceAvailable()) {
        onConnectionRestored(); // Llama al callback
      } else {
        if(context.mounted){
          showPersistentConnectionCard(context, onConnectionRestored);
        }
      }
    } else {
      if(context.mounted){
        showPersistentConnectionCard(context, onConnectionRestored);
      }
    }
  }
}
