

import 'package:intl/intl.dart';

class DateHelpers {
  static String getStartDate() {
    var _date = DateTime.now();
    String minute = _date.minute < 10 ? '0${_date.minute}' : _date.minute.toString();
    String second = _date.second < 10 ? '0${_date.second}' : _date.second.toString();

    // Usar DateFormat para obtener el nombre del mes en español
    String monthName = DateFormat('MMMM', 'es').format(_date);

    return "${_date.day} de $monthName/${_date.year} - ${_date.hour}:$minute:$second";
  }
}



