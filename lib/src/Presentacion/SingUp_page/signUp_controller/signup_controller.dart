
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Helpers/Dates/DateHelpers.dart';
import '../../../../Helpers/My_progress_dialog/myProgressDialog.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/client_provider.dart';
import 'package:zafiro_cliente/src/models/client.dart';

class SignUpController{

 late BuildContext  context;
 GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController nombresController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController numeroDocumentoController = TextEditingController();
  TextEditingController fechaExpedicionDocumentoController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailConfirmarController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmarController = TextEditingController();

  String tipoDocumento= "";
  String fechaExpedicion= "";
  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late ProgressDialog _progressDialog;

  Future? init (BuildContext context) {
  this.context = context;
  _authProvider = MyAuthProvider();
  _clientProvider = ClientProvider();
  iniciarPreferencias();
  _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espera un momento ...')!;
  return null;
  }

 void iniciarPreferencias() async {
   SharedPreferences sharepreferences = await SharedPreferences.getInstance();
   tipoDocumento= sharepreferences.getString('tipoDoc') ?? "Cédula de Ciudadanía";
   fechaExpedicion= sharepreferences.getString('fechaExpedicion') ?? "";
 }

 void borrarPref() async {
   SharedPreferences sharepreferences = await SharedPreferences.getInstance();
   sharepreferences.remove('tipoDoc');
   sharepreferences.remove('fechaExpedicion');
 }

 void _goTakeFotoPerfil(){
   Navigator.pushNamed(context, 'take_foto_perfil');
 }

  void signUp() async {
    iniciarPreferencias();
    String nombres= nombresController.text;
    String apellidos= apellidosController.text;
    String numeroDocumento= numeroDocumentoController.text;
    String celular= celularController.text;
    String email= emailController.text.trim();
    String emailConfirmar= emailConfirmarController.text.trim();
    String password= passwordController.text.trim();
    String passwordConfirmar= passwordConfirmarController.text.trim();

    if(nombres.isEmpty || apellidos.isEmpty || numeroDocumento.isEmpty || celular.isEmpty || email.isEmpty
    || emailConfirmar.isEmpty || password.isEmpty || passwordConfirmar.isEmpty){
     Snackbar.showSnackbar(context, key, 'No debe haber ningún campo vacio');
      return;
    }

    if(passwordConfirmar != password){
      Snackbar.showSnackbar(context, key, 'Las contraseñas no coinciden');
      return;
    }

    if(password.length < 6){
      Snackbar.showSnackbar(context, key, 'La contraseña debe tener mínimo 6 caracteres');
      return;
    }

    if(celular.length != 10){
      Snackbar.showSnackbar(context, key, 'El número celular no es válido');
      return;
    }

    if( numeroDocumento.length < 7 ||  numeroDocumento.length > 12 ){
      Snackbar.showSnackbar(context, key, 'El número de identificación no es válido');
      return;
    }

    if(email != emailConfirmar){
      Snackbar.showSnackbar(context, key, 'Las direcciones de correo no coinciden');
      return;
    }
    _progressDialog.show();

    try{
     bool isSignUp =  await _authProvider.signUp(email, password);
     if(isSignUp){
        Client client = Client(
           id: _authProvider.getUser()!.uid,
           the01Nombres: nombres,
           the02Apellidos: apellidos,
           the03TipoDeDocumento: tipoDocumento,
           the04NumeroDocumento: numeroDocumento,
           the05FechaExpedicionDocumento: fechaExpedicion,
           the06Email: email,
           the07Celular: celular,
           the08FechaNacimiento: "",
           the09Genero: "",
           the10EstaActivado: false,
           the11FechaActivacion: "",
           the12NombreActivador: "",
           the13FotoCedulaDelantera: "",
           the14FotoCedulaTrasera: "",
           the15FotoPerfilUsuario: "",
           the16EstaBloqueado: false,
           the17Bono: 0,
           the18Calificacion: 0,
           the19Viajes: 0,
           the20Rol: "basico",
           the21FechaDeRegistro: DateHelpers.getStartDate(),
           token: "",
           image: "",
           fotoCedulaDelantera: "",
           fotoCedulaTrasera: "",
           verificacionStatus: "",
           the00isTraveling: false,
           the22Cancelaciones: 0,
          the41SuspendidoPorCancelaciones: false,
          ceduladelanteraTomada: false,
          cedulatraseraTomada: false,
          fotoPerfilTomada: false
          );

       await _clientProvider.create(client);
       _progressDialog.hide();
        _goTakeFotoPerfil();
        borrarPref();
     }
     else{
       _progressDialog.hide();
     }
    }catch (error) {
      _progressDialog.hide();
      if (kDebugMode) {
        print('Error durante el registro: $error');
      }

      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          Snackbar.showSnackbar(key.currentContext!, key,
              'El correo electrónico ya está en uso por otra cuenta.');
        } else {
          Snackbar.showSnackbar(key.currentContext!, key,
              'Ocurrió un error durante el registro. Por favor, inténtalo nuevamente.');
        }
      } else {
        Snackbar.showSnackbar(key.currentContext!, key,
            'Ocurrió un error durante el registro. Por favor, inténtalo nuevamente.');
      }
    }
  }
}

