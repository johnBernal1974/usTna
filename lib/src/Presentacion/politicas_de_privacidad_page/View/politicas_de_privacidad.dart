import 'package:flutter/material.dart';
import '../../../colors/colors.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class PoliticasDePrivacidadPage extends StatefulWidget {
  const PoliticasDePrivacidadPage({super.key});

  @override
  State<PoliticasDePrivacidadPage> createState() => _PoliticasDePrivacidadPageState();
}

class _PoliticasDePrivacidadPageState extends State<PoliticasDePrivacidadPage> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blancoCards,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
            text: "Privacidad",
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: negro
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse('https://mizafiro.com/politicas-de-privacidad/'),
            ),
            onWebViewCreated: (InAppWebViewController controller){
              inAppWebViewController = controller;
            },
            onProgressChanged:(InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
          _progress < 1 ? LinearProgressIndicator(
            backgroundColor: primary,
            minHeight: 8,
            value: _progress,
          ): const SizedBox()
        ],
      ),
    );
  }
}
