import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final String texto; // = "",
  final Color color; //= Colors.black,
  final FontWeight fontWeight; //= FontWeight.bold,
  final double? fontSize;
  final TextAlign textAlign; //= TextAlign.justif
  final int? maxLines;

  const TextView({ this.texto = "",
                   this.color = Colors.black,
                   this.fontWeight = FontWeight.bold,
                   this.fontSize,
                   this.textAlign = TextAlign.justify,
                   this.maxLines = 2 });

  @override
  Widget build(BuildContext context) {
    return Text(texto,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        style: TextStyle(color: color, 
                         fontWeight: fontWeight, 
                         fontSize: fontSize, 
                         letterSpacing: -0.3));
  }
}
