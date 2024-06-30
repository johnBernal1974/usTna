import 'package:flutter/material.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class CompartirAplicacionpage extends StatelessWidget {
  const CompartirAplicacionpage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "Compartir aplicación",
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: negro
        ),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 60.0,
              image: AssetImage('assets/images/compartir_app.png'))

        ],
      ),
      body: Container(
          padding: EdgeInsets.all(25),
          alignment: Alignment.center,
          child: Column(
            children: [
              headerText(
                text: 'Comparte Tay-rona con tus amigos, familiares y personas queridas, para que ellos tampoco paren de viajar.',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: negroLetras,
              ),
              const Divider(color: grisMedio),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                            child: const Image(
                                height: 80.0,
                                width: 80.0,
                                image: AssetImage('assets/images/app_tayrona_cliente_compartir.png')),
                          ),

                          const Image(
                              height: 45.0,
                              width: 45.0,
                              image: AssetImage('assets/images/icono_compartir_circular.png')),
                        ],
                      ),

                      headerText(
                        text: 'Tay-rona\nCliente',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: negroLetras,
                      ),

                    ],
                  ),

                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                            child: const Image(
                                height: 80.0,
                                width: 80.0,
                                image: AssetImage('assets/images/app_tayrona_conductor_compartir.png')),
                          ),

                          const Image(
                              height: 45.0,
                              width: 45.0,
                              image: AssetImage('assets/images/icono_compartir_circular.png')),
                        ],
                      ),

                      headerText(
                        text: 'Tay-rona\nConductor',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: negroLetras,
                      ),

                    ],
                  ),
                ],
              )
            ],
          )),
    );

  }
}
