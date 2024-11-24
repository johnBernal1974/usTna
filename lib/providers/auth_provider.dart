
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zafiro_cliente/src/models/client.dart';
import '../src/colors/colors.dart';
import 'client_provider.dart';

class MyAuthProvider{
  late FirebaseAuth _firebaseAuth;
  final ClientProvider _clientProvider = ClientProvider();


  MyAuthProvider(){
    _firebaseAuth = FirebaseAuth.instance;
  }

  BuildContext? get context => null;

  Future<bool> login(String email, String password, BuildContext context) async {
    String? errorMessage;

    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (error){
      errorMessage = _getErrorMessage(error.code);
      if(context.mounted){
        showSnackbar(context, errorMessage);
      }
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
          // Verificar si el correo electrónico está verificado
          if (!user.emailVerified) {
            // Si no está verificado, redirigir a la página de verificación de correo electrónico
            Navigator.pushNamedAndRemoveUntil(context, 'email_verification_page', (route) => false);
            return;
          }

          ClientProvider clientProvider = ClientProvider();
          String? verificationStatus = await clientProvider.getVerificationStatus();

          // Verificar si el estado de verificación está en "Procesando"
          if (verificationStatus == 'Procesando' || verificationStatus == 'corregida') {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
            }
            return;
          }

          if (verificationStatus == 'bloqueado') {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'bloqueo_page', (route) => false);
            }
            return;
          }

          // Verificar las fotos en el orden especificado
          String? fotoPerfilUsuario = await clientProvider.verificarFotoPerfil();

          if (fotoPerfilUsuario == "" || fotoPerfilUsuario == "rechazada") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_foto_perfil', (route) => false);
            }
            return;
          }

          String? fotoCedulaDelantera = await clientProvider.verificarFotoCedulaDelantera();
          String? fotoCedulaTrasera = await clientProvider.verificarFotoCedulaTrasera();

          // Esta línea es para verificar si puede ver el valor de un servicio antes de pedirle la cédula
          if (fotoCedulaDelantera == "" || fotoCedulaTrasera == "") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
            }
            return;
          }

          if (fotoCedulaDelantera == "rechazada") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_delantera_page', (route) => false);
            }
            return;
          }

          if (fotoCedulaTrasera == "rechazada") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
            }
            return;
          }

          // Si todas las fotos están verificadas, verificar si el usuario está viajando
          String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          Client? client = await clientProvider.getById(userId);
          if (client != null) {
            bool isTraveling = client.the00isTraveling;
            if (isTraveling) {
              if(context.mounted){
                Navigator.pushNamedAndRemoveUntil(context, 'travel_map_page', (route) => false);
              }
            } else {
              if(context.mounted){
                Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
              }
            }
          } else {
            // Si no se encuentra el cliente, redirigir a 'map_client'
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'map_client', (route) => false);
            }
          }
        } else {
          if(context.mounted){
            Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
          }
        }
      });
    }
  }

  void verificarFotosCedulaDelantera(BuildContext? context) {
    if (context != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          ClientProvider clientProvider = ClientProvider();
          String? fotoCedulaDelantera = await clientProvider.verificarFotoCedulaDelantera();
          if (fotoCedulaDelantera == "" || fotoCedulaDelantera == "rechazada") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_delantera_page', (route) => false);
            }
          } else {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
            }
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      });
    } else {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
    }
  }

  void verificarFotosCedulaTrasera(BuildContext? context) {
    if (context != null) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          ClientProvider clientProvider = ClientProvider();
          String? fotoCedulaTrasera = await clientProvider.verificarFotoCedulaTrasera();
          if (fotoCedulaTrasera == "" || fotoCedulaTrasera == "rechazada") {
            if(context.mounted){
              Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
            }
          } else {
            if(context.mounted){
              updateStatusProcesando();
              Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);

            }
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      });
    } else {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
    }
  }

  void updateStatusProcesando() async {
    String? userId = getUser()?.uid;
    if (userId != null) {

      Client? client = await _clientProvider.getById(userId);
      if (client != null) {
        Map<String, dynamic> data = {
          'Verificacion_Status': "Procesando",
        };
        await _clientProvider.update(data, userId);
      } else {
        if (kDebugMode) {
          print("Error: No se encontró el cliente para el ID $userId");
        }
      }
    } else {
      if (kDebugMode) {
        print("Error: Usuario no autenticado o ID inválido.");
      }
    }
  }



  Future<bool> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      // Lanzar el error para manejarlo en SignUpController
      rethrow;
    }
    return true;
  }

  Future<void> signOut() async {
    String? userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      await _firebaseAuth.signOut();
    }
  }

  Future<bool> isUserLoggedIn() async {
    // Si usas Firebase Authentication
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

}