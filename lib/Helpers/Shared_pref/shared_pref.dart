import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {

  void save ( String key, String value) async {
    final prefs= await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

    Future<dynamic> read (String key) async{
    final prefs= await SharedPreferences.getInstance();
    return json.decode(prefs.getKeys() as String);
  }

   Future<bool> contains(String key) async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key)async{
    final prefs= await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}