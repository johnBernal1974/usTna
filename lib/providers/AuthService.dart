

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Envío de correo de restablecimiento exitoso
      print('Correo de restablecimiento enviado correctamente');
    } catch (e) {
      print('Error al enviar el correo de restablecimiento: $e');

      // Manejo de errores específicos
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          print('Usuario no encontrado');
          // Manejar el caso en que el usuario no está registrado
        } else {
          print('Código de error: ${e.code}');
          print('Mensaje de error: ${e.message}');
          // Manejar otros errores
        }
      } else {
        // Manejar errores generales
        print('Error general: $e');
      }
    }
  }
}

