import 'package:flutter/material.dart';

import '../Texts/TextView/View/TextView.dart';

// Principle Function
Widget createElevatedButton(
    { BuildContext? context,
      double width = 350.0,
      double height = 45.0,
      double radius = 8.0,
      bool isWithIcon = false,
      ImageProvider<Object>? icon,
      String? labelButton,
      double labelFontSize = 15,
      Color labelColor = Colors.white,
      Color color = Colors.blue,
      OutlinedBorder? shape,
      Function()? func}) {
  return Container(
    width: width,
    height: height,
    margin: const EdgeInsets.only(top: 20.0),
    child: isWithIcon && icon != null
        ? _createElevatedButtonWithIcon(radius, icon, labelButton ?? "",
        labelFontSize, labelColor, color, shape ?? const StadiumBorder(), func)
        : _createElevatedButtonNotIcon(radius, labelButton ?? "", labelFontSize,
        labelColor, color, shape ?? const StadiumBorder(), func),
  );
}

// Button With Icon
Widget _createElevatedButtonWithIcon(
    double radius,
    ImageProvider<Object> icon,
    String labelButton,
    double labelFontSize,
    Color labelColor,
    Color color,
    OutlinedBorder shape,
    Function()? func) {
  return ElevatedButton(
      onPressed: func,
      style: ElevatedButton.styleFrom(
          shape: shape, primary: color, elevation: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: icon,
            width: 20.0,
            height: 20.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0),
            child: TextView(
                texto: labelButton,
                color: labelColor,
                fontSize: labelFontSize,
                fontWeight: FontWeight.bold),
          )
        ],
      ));
}

// Button Without Icon
Widget _createElevatedButtonNotIcon(
    double radius,
    String labelButton,
    double labelFontSize,
    Color labelColor,
    Color color,
    OutlinedBorder shape,
    Function()? func) {
  return ElevatedButton(
      onPressed: func,
      style: ElevatedButton.styleFrom(shape: shape, backgroundColor: color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: TextView(
                texto: labelButton,
                color: labelColor,
                fontSize: labelFontSize,
                fontWeight: FontWeight.bold),
          )
        ],
      ));
}
