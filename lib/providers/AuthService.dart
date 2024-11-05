

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar el correo de restablecimiento: $e');
      }

      // Manejo de errores específicos
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          if (kDebugMode) {
            print('Usuario no encontrado');
          }
          // Manejar el caso en que el usuario no está registrado
        } else {
          if (kDebugMode) {
            print('Código de error: ${e.code}');
          }
          if (kDebugMode) {
            print('Mensaje de error: ${e.message}');
          }
          // Manejar otros errores
        }
      } else {
        // Manejar errores generales
        if (kDebugMode) {
          print('Error general: $e');
        }
      }
    }
  }
}

