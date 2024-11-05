import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../src/api/acces_firebase_token.dart';
import 'client_provider.dart';

class PushNotificationsProvider {
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  final StreamController<Map<String, dynamic>> _streamController = StreamController.broadcast();
  Stream get message => _streamController.stream;

  PushNotificationsProvider() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void initPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _streamController.sink.add(message.data);

      // Mostrar una notificación local
      _showLocalNotification(message.notification?.title, message.notification?.body, message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('OnResume $message');
      _streamController.sink.add(message.data);
    });
  }

  Future<void> _showLocalNotification(String? title, String? body, Map<String, dynamic> data) async {
    // Extract data from the payload
    String data1 = data['data1'] ?? 'N/A';
    String data2 = data['data2'] ?? 'N/A';
    String data3 = data['data3'] ?? 'N/A';

    // Create a notification with buttons
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      '$body\n\nData 1: $data1\nData 2: $data2\nData 3: $data3', // Cuerpo de la notificación
      platformChannelSpecifics,
    );

  }

  void saveToken(String? idUser) async {
    String? token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = {
      'token': token,
    };
    ClientProvider clientProvider = ClientProvider();
    clientProvider.update(data, idUser!);
  }

  Future<void> sendMessage(String to, Map<String, dynamic> data) async {
    AccessTokenFirebase accessTokenFirebase = AccessTokenFirebase();
    String token = await accessTokenFirebase.getAccessToken();

    String tarifaFormateada = NumberFormat.currency(
      locale: 'es',
      symbol: '',  // Para que no agregue ningún símbolo automáticamente
      decimalDigits: 0,  // Sin decimales
    ).format(int.parse(data['tarifa']));

    // Definir el contenido de la notificación
    final notification = {
      'title': 'Zafiro',
      //'body': 'Destino: ${data['destination']}, Tarifa: \$${tarifaFormateada}',
      'body': 'Nueva solicitud de servicio',
    };

    // Enviar la notificación a través de Firebase Cloud Messaging
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/transport-f7c79/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'message': {
          'token': to,
          'notification': notification, // Notificación con título y cuerpo
          'data': data, // Datos adicionales
          'android': {
            'ttl': '25s',
            'notification': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'icon': 'logo_compartir_zafiro', // Icono solo para Android
              'sound': 'notification_sound', // Sonido personalizado
            },
          },
          'apns': {
            'headers': {
              'apns-expiration': '25',
            },
            'payload': {
              'aps': {
                'sound': 'default', // O usa un sonido personalizado aquí también
              },
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Mensaje enviado exitosamente.');
      }
    } else {
      if (kDebugMode) {
        print('Error al enviar el mensaje: ${response.body}');
      }
    }
  }

}
