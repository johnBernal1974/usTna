import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:tayrona_usuario/src/api/acces_firebase_token.dart';
import 'client_provider.dart';

class PushNotificationsProvider {

  late FirebaseMessaging _firebaseMessaging ;
  final StreamController _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream get message => _streamController.stream;

  PushNotificationsProvider() {
    _firebaseMessaging = FirebaseMessaging.instance;
  }



  void initPushNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Cuando estamos en primer plano');
      print('OnMessage: $message');
      _streamController.sink.add(message.data);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('OnResume $message');
      _streamController.sink.add(message.data);
      });

    }

    void saveToken(String? idUser) async {
      String? token = await _firebaseMessaging.getToken();
      Map<String, dynamic> data = {
        'token': token
      };
      ClientProvider clientProvider = ClientProvider();
      clientProvider.update(data, idUser!);
    }

  Future<void> sendMessage(String to, Map<String, dynamic> data) async {
   AccessTokenFirebase accessTokenFirebase = AccessTokenFirebase();
   String token = await accessTokenFirebase.getAccessToken();
   //String serverKey = token;

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/tay-rona-flutter/messages:send'), // Reemplaza "your-project-id" con tu ID de proyecto de Firebase
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'message': <String, dynamic>{
          'token': to, // El token del dispositivo de destino
          'notification': <String, dynamic>{
            'title': 'SOLICITUD DE SERVICIO',
            'body': 'Un usuario requiere de tu servicio',
          },
          'data': data, // Datos adicionales del mensaje
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Mensaje enviado exitosamente.');
    } else {
      print('Error al enviar el mensaje: ${response.body}');
    }
  }

    void dispose() {
      _streamController?.onCancel;
    }

}