
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static String firebaseMessagingScope = "https://www.googleapis.com/auth/firebase.messaging";
  Future<String> getAccessToken() async {
    final client = clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
      {
        "type": "service_account",
        "project_id":  dotenv.env['PROJECT_ID']!,
        "private_key_id": dotenv.env['PRIVATE_KEY_ID']!,
        "private_key": dotenv.env['PRIVATE_KEY']!.replaceAll(r'\n', '\n'),
        "client_email": dotenv.env['CLIENT_EMAIL']!,
        "client_id": dotenv.env['CLIENT_ID']!,
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": dotenv.env['CLIENT_X509']!,
        "universe_domain": "googleapis.com"
      },
    ),
    [firebaseMessagingScope]);

    final accessToken = (await client).credentials.accessToken.data;

    return accessToken;

  }
}