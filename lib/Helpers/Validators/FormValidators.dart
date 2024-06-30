
import 'package:intl/intl.dart';

class EmailFormValidator {
  static String message = 'El email no es válido';
  static String? validateEmail({ required String email })  {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp  = RegExp(pattern);

    return regExp.hasMatch(email) ? null : message;
  }
}

class PasswordFormValidator {
  static String message = 'La contraseña no es correcta';
  static String? validatePassword({ required String password }) {
    return password.isNotEmpty && password.length >= 6 ? null : message;
  }
}

class DefaultFormValidator {
  static String message = 'El campo está vacío';
  static String? validateIsNotEmpty({ required String value }) {
    return value.isNotEmpty ? null : message;
  }
}

class CelularFormValidator {
  static String message = 'El celular no es correcto';
  static String? validateCelular({ required String value }) {
    return value.isNotEmpty && value.length >= 10 ? null : message;
  }
}

class FormatUtils {
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
    String formatted = formatter.format(amount);
    return formatted.replaceAll(',', '.');
  }
}




