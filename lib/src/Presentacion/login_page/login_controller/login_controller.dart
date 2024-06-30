
import 'package:flutter/material.dart';
import 'package:tayrona_usuario/Helpers/SnackBar/snackbar.dart';
import 'package:tayrona_usuario/providers/client_provider.dart';
import 'package:tayrona_usuario/src/models/client.dart';

import '../../../../providers/auth_provider.dart';

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
    String email= emailController.text.trim();
    String password= passwordController.text.trim();
    print('Email: $email');
    print('Password: $password');

    if( email.isEmpty && password.isEmpty ){
      Snackbar.showSnackbar(context, key, 'No has ingresado ningún valor');
      return;
    }

    if( email.isEmpty ){
      Snackbar.showSnackbar(context, key, 'Debes ingresar tu correo electrónico');
      return;
    }

    if(password.isEmpty ){
      Snackbar.showSnackbar(context, key, 'Debes ingresar tu contraseña');
      return;
    }

    if(password.length < 6){
      Snackbar.showSnackbar(context, key, 'La contraseña debe tener mínimo 6 caracteres');
      return;
    }

    showSimpleAlertDialog(context, 'Espera un momento ...');

    try{
      bool isLoginSuccessful = await _authProvider.login(email, password, context);
      if(isLoginSuccessful){
       Client? client =  await _clientProvider.getById(_authProvider.getUser()!.uid);
       if(client != null){
         _authProvider.checkIfUserIsLogged(context);
       }
       else{
         Snackbar.showSnackbar(context, key, 'Este usuario no es válido');
         await _authProvider.signOut();
       }

     }

    } on MyAuthProvider catch(error){
      Snackbar.showSnackbar(context, key, 'Error: $error');
    }finally {
      closeSimpleProgressDialog(context);
    }
   }
}

