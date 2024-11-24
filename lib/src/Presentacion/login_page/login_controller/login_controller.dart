
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import 'package:zafiro_cliente/src/models/client.dart';

class LoginController{

 late BuildContext  context;
 GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

 late MyAuthProvider _authProvider;
 late ClientProvider _clientProvider;

  Future? init (BuildContext context) {
  this.context = context;
  _authProvider = MyAuthProvider();
  _clientProvider = ClientProvider();
  return null;
  }

 void showSimpleAlertDialog(BuildContext context, String message) {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const CircularProgressIndicator(),
             const SizedBox(height: 16),
             Text(message),
           ],
         ),
       );
     },
   );
 }

 void closeSimpleProgressDialog(BuildContext context) {
   Navigator.of(context).pop();
 }

  void goToRegisterPage(){
    Navigator.pushNamed(context, 'signup');
  }

 void goToForgotPassword(){
   Navigator.pushNamed(context, 'forgot_password');
 }

 void login() async {
   String email = emailController.text.trim();
   String password = passwordController.text.trim();

   if (email.isEmpty || password.isEmpty) {
     Snackbar.showSnackbar(context, key, 'Debes ingresar tus credenciales');
     return;
   }
   if (password.length < 6) {
     Snackbar.showSnackbar(context, key, 'La contraseña debe tener mínimo 6 caracteres');
     return;
   }

   showSimpleAlertDialog(context, 'Espera un momento ...');

   try {
     bool isLoginSuccessful = await _authProvider.login(email, password, context);

     if (isLoginSuccessful) {
       Client? client = await _clientProvider.getById(_authProvider.getUser()!.uid);

       if (client != null) {
         bool isLoggedIn = await _clientProvider.checkIfUserIsLoggedIn(client.id);

         if (isLoggedIn) {
           if (context.mounted) {
             Snackbar.showSnackbar(
               context,
               key,
               'Este usuario ya está logueado en otro dispositivo. Por favor, cierre sesión en el otro equipo para continuar.'
             );
           }
           await _authProvider.signOut();
           return;
         }

         // Actualizar estado como conectado
         await _clientProvider.updateLoginStatus(client.id, true);

         if (context.mounted) {
           _authProvider.checkIfUserIsLogged(context);
         }
       } else {
         // Manejo de cliente no válido
         if (context.mounted) {
           Snackbar.showSnackbar(context, key, 'Este usuario no es válido');
         }
         await _authProvider.signOut();
       }
     }
   } catch (error) {
     if (context.mounted) {
       Snackbar.showSnackbar(context, key, 'Error: $error');
     }
   } finally {
     if (context.mounted) {
       closeSimpleProgressDialog(context);
     }
   }
 }


}

