import 'package:flutter/material.dart';
import '../../../../../colors/colors.dart';
import '../../TextView/View/TextView.dart';

class DoubleTextView extends StatelessWidget {

  final String textHeader;
  final String textAction;
  final Function()? textActionTapped;

  const DoubleTextView({  
    required this.textHeader,
    required this.textAction,
    this.textActionTapped
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    child: Row(
      children: [
        TextView(texto: textHeader, fontSize: 20.0),
        const Spacer(),
        GestureDetector(
          onTap: textActionTapped,
          child: TextView(
              texto: textAction,
              color: primary,
              fontWeight: FontWeight.w500,
              fontSize: 15.0),
        )
      ],
    ),
  );
  }
}




/*
GestureDetector(
            onTap: textActionTapped,
            child: TextView(
                texto: textAction,
                color: orange,
                fontWeight: FontWeight.w500,
                fontSize: 15.0)
 */