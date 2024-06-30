import 'package:flutter/material.dart';
import 'package:tayrona_usuario/src/colors/colors.dart';

import '../Buttons/rounded_button.dart';
import '../headers/header_text/header_text.dart';

class ErrorAlertView{

  static Future showErrorAlertDialog({ required BuildContext context,
                                       required String subtitle,
                                       dynamic Function()? ctaButtonAction}) async {
    return showDialog(context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context){
      return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
        content: SizedBox(
          height: 320,
          child: Column(
            children: [
              const Icon(Icons.wifi_off, color: blanco, size: 55),
              Container(
                margin: const EdgeInsets.all(15),
                child: headerText(
                  text: 'Sin Coneccion a internet',
                  color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: headerText(
                    text: subtitle,
                    color: gris,
                    fontSize: 15,
                    fontWeight: FontWeight.w400
                ),
              ),

              createElevatedButton(
                  context: context,
                  icon: null,
                  labelButton: 'Ir a inicio',
                  color: primary,
                  func: ctaButtonAction)

            ],
          ),

        ),
      );
    });

  }
}