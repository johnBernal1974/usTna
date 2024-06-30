import 'package:flutter/material.dart';

import '../../../../colors/colors.dart';

Widget headerText(
    {
      String text = "",
      Color color= negro,
      FontWeight fontWeight = FontWeight.bold,
      double? fontSize,
      TextAlign textAling = TextAlign.center


    }){
  // ignore: prefer_typing_uninitialized_variables

  return  Text(text,
      textAlign: textAling,
      style:
      TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize ));

}