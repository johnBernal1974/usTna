
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tayrona_usuario/src/models/client.dart';
import '../src/colors/colors.dart';
import 'client_provider.dart';

class MyAuthProvider{
  late FirebaseAuth _firebaseAuth;


  MyAuthProvider(){
    _firebaseAuth = FirebaseAuth.instance;
  }

  BuildContext? get context => null;

  Future<bool> login(String email, String password, BuildContext context) async {
    String? errorMessage;

    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (error){
      print('ErrorxxxdelLogin: ${error.code} \n ${error.message}');
      errorMessage = _getErrorMessage(error.code);
      showSnackbar(context, errorMessage ?? "");
      return false;
    }
    return true;
  }

  String _getErrorMessage(String errorCode) {
    // Mapeo de los códigos de error a mensajes en español
    Map<String, String> errorMessages = {
      'user-not-found': 'Usuario no encontrado. Verifica tu correo electrónico.',
      'wrong-password': 'Contraseña incorrecta. Inténtalo de nuevo.',
      'invalid-email': 'La dirección de correo electrónico no tiene el formato correcto.',
      'user-disabled': 'La cuenta de usuario ha sido deshabilitada.',
      'invalid-credential': 'Las credenciales proporcionadas no son válidas.',
      'network-request-failed': 'Sin señal. Revisa tu conexión de INTERNET.',
      'email-already-in-use': 'El correo electrónico ingresado ya está siendo usado por otro usuario.',
    };

    return errorMessages[errorCode] ?? 'Error desconocido';
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: rojo,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  User? getUser(){
    return _firebaseAuth.currentUser;
  }

  void checkIfUserIsLogged(BuildContext? context) {
    if (context != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          print('El usuario está logueado');

          ClientProvider clientProvider = ClientProvider();
          String? verificationStatus = await clientProvider.getVerificationStatus();

          // Verificar si el estado de verificación está en "Procesando"
          if (verificationStatus == 'Procesando' || verificationStatus == 'corregida') {
            Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
            return;
          }

          // Verifica el estado de verificación
          if (verificationStatus == 'bloqueado') {
            Navigator.pushNamedAndRemoveUntil(context, 'bloqueo_page', (route) => false);
            return;
          }

          // Verificar las fotos en el orden especificado
          String? fotoPerfilVerificada = await clientProvider.verificarFotoPerfil();
          if (fotoPerfilVerificada == "" || fotoPerfilVerificada == "rechazada") {
            Navigator.pushNamedAndRemoveUntil(context, 'take_foto_perfil', (route) => false);
            return;
          }

          String? fotoCedulaDelantera = await clientProvider.verificarFotoCedulaDelantera();
          if (fotoCedulaDelantera == "" || fotoCedulaDelantera == "rechazada") {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_delantera_page', (route) => false);
            return;
          }

          String? fotoCedulaTrasera = await clientProvider.verificarFotoCedulaTrasera();
          if (fotoCedulaTrasera == "" || fotoCedulaTrasera == "rechazada") {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
            return;
          }

          // Si todas las fotos están verificadas, verificar si el usuario está viajando
          String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          Client? client = await clientProvider.getById(userId);

          if (client != null) {
            bool isTraveling = client.the00isTraveling;
            if (isTraveling) {
              Navigator.pushNamedAndRemoveUntil(context, 'travel_map_page', (route) => false);
            } else {
              // Si no se encuentra un viaje actual, redirigir a 'map_client'
              print('No hay un viaje actual para este conductor');
              Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
            }
          } else {
            // Si no se encuentra el cliente, redirigir a 'map_client'
            Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
          print('El usuario NO está logueado');
        }
      });
    }
  }


  void verificarFotosCedulaDelantera(BuildContext? context) {
    if (context != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          print('El usuario está logueado');
          ClientProvider clientProvider = ClientProvider();
          // Verificar si las fotos ya han sido cargadas

          String? fotoCedulaDelanteraVerificada = await clientProvider.verificarFotoCedulaDelantera();

          // Verificar si las fotos están verificadas
          if (fotoCedulaDelanteraVerificada == "" || fotoCedulaDelanteraVerificada == "rechazada") {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_delantera_page', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
          print('El usuario NO está logueado');
        }
      });
    } else {
      print('El contexto es nulo');
      // Manejar el caso en que el contexto sea nulo, por ejemplo, mostrando un mensaje de error.
    }
  }

  void verificarFotosCedulaTrasera(BuildContext? context) {
    if (context != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          print('El usuario está logueado');
          ClientProvider clientProvider = ClientProvider();
          String? fotoCedulaTraseraVerificada = await clientProvider.verificarFotoCedulaTrasera();
          if (fotoCedulaTraseraVerificada == "" || fotoCedulaTraseraVerificada == "rechazada") {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
          print('El usuario NO está logueado');
        }
      });
    } else {
      print('El contexto es nulo');
      // Manejar el caso en que el contexto sea nulo, por ejemplo, mostrando un mensaje de error.
    }
  }

  Future<bool> signUp(String email, String password) async {
    String? errorMessage;

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      errorMessage = error.code;
      // Lanzar el error para manejarlo en SignUpController
      rethrow;
    }
    return true;
  }

  Future<Future<List<void>>> signOut() async {
    return Future.wait([_firebaseAuth.signOut()]);

  }

}