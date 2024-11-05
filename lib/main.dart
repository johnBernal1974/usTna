

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zafiro_cliente/src/Presentacion/Forgot_PasswordPage/forgot_password_page.dart';
import 'package:zafiro_cliente/src/Presentacion/SingUp_page/View/singup_page.dart';
import 'package:zafiro_cliente/src/Presentacion/bloqueo_page/bloqueo_page.dart';
import 'package:zafiro_cliente/src/Presentacion/compartir_aplicacion_page/View/compartir_aplicacion_page.dart';
import 'package:zafiro_cliente/src/Presentacion/contactanos_page/View/contactanos_page.dart';
import 'package:zafiro_cliente/src/Presentacion/detail_history_page/detail_history_page.dart';
import 'package:zafiro_cliente/src/Presentacion/eliminar_Cuenta_page/eliminar_cuenta_page.dart';
import 'package:zafiro_cliente/src/Presentacion/email_verificationPage/email_verification_page.dart';
import 'package:zafiro_cliente/src/Presentacion/historial_viajes_page/View/historial_viajes_page.dart';
import 'package:zafiro_cliente/src/Presentacion/info_seguridad_page/View/info_seguridad_page.dart';
import 'package:zafiro_cliente/src/Presentacion/login_page/View/login_page.dart';
import 'package:zafiro_cliente/src/Presentacion/map_client_page/View/map_client_page.dart';
import 'package:zafiro_cliente/src/Presentacion/politicas_de_privacidad_page/View/politicas_de_privacidad.dart';
import 'package:zafiro_cliente/src/Presentacion/profile_page/profile_page.dart';
import 'package:zafiro_cliente/src/Presentacion/splash_page/splash_page.dart';
import 'package:zafiro_cliente/src/Presentacion/take_Photo_Cedula_Delantera/View/take_photo_cedula_delantera_page.dart';
import 'package:zafiro_cliente/src/Presentacion/take_Photo_Cedula_Trasera/View/take_photo_cedula_trasera_page.dart';
import 'package:zafiro_cliente/src/Presentacion/take_foto_perfil/take_foto_perfil.dart';
import 'package:zafiro_cliente/src/Presentacion/travel_calification_page/View/travel_calification_page.dart';
import 'package:zafiro_cliente/src/Presentacion/travel_info_page/travel_info_page.dart';
import 'package:zafiro_cliente/src/Presentacion/travel_map_page/View/travel_map_page.dart';
import 'package:zafiro_cliente/src/Presentacion/verifying_identity_page/View/verifying_identity_page.dart';
import 'controllerNetwork/dependecy_injection.dart';
import 'src/colors/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Asegura que Flutter esté inicializado antes de cargar otros recursos
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno del archivo .env
  await dotenv.load(fileName: ".env");

  // Establecer la orientación preferida
  await _setPreferredOrientations();

  // Configurar estilo de la barra de estado
  _setSystemUIOverlayStyle();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar inyección de dependencias
  DependencyInjection.init();

  // Correr la aplicación
  runApp(const MyApp());
}

Future<void> _setPreferredOrientations() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void _setSystemUIOverlayStyle() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cliente",
      initialRoute: "splash",

      routes: {
        'splash': (BuildContext context) => const SplashPage(),
        'login': (BuildContext context) => LoginPage(),
        'signup': (BuildContext context) => SignUpPage(),
        'verifying_identity': (BuildContext context) => const VerifyingIdentityPage(),
        'map_client': (BuildContext context) => const MapClientPage(),
        'historial_viajes': (BuildContext context) => const HistorialViajesPage(),
        'contactanos': (BuildContext context) => const ContactanosPage(),
        'compartir_aplicacion': (BuildContext context) => const CompartirAplicacionpage(),
        'forgot_password': (BuildContext context) => const ForgotPage(),
        'profile': (BuildContext context) => const ProfilePage(),
        'politicas_de_privacidad': (BuildContext context) => const PoliticasDePrivacidadPage(),
        'eliminar_cuenta': (BuildContext context) => const EliminarCuentaPage(),
        'take_foto_perfil': (BuildContext context) => const TakeFotoPerfil(),
        'travel_info_page': (BuildContext context) => const ClientTravelInfoPage(),
        'info_seguridad_page': (BuildContext context) => const InfoSeguridadPage(),
        'take_photo_cedula_delantera_page': (BuildContext context) => const TakePhotoCedulaDelanteraPage(),
        'take_photo_cedula_trasera_page': (BuildContext context) => const TakePhotoCedulaTraseraPage(),
        'travel_map_page': (BuildContext context) => const TravelMapPage(),
        'travel_calification_page': (BuildContext context) => const TravelCalificationPage(),
        'detail_history_page': (BuildContext context) => const DetailHistoryPage(),
        'bloqueo_page': (BuildContext context) =>  PaginaDeBloqueo(),
        'email_verification_page': (BuildContext context) =>  EmailVerificationPage()

      },
      theme: ThemeData(
        scaffoldBackgroundColor: blancoCards,
       // primaryColor: primary, fontFamily: 'Gilroy'
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('es', ''), // Spanish, no country code
      ],
    );
  }
}
