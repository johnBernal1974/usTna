

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../providers/auth_provider.dart';
import '../../colors/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  late MyAuthProvider _authProvider;

  @override
  void initState() {
    _authProvider = MyAuthProvider();
    super.initState();
    var d = const Duration(seconds: 4);
    Future.delayed(d, (){
      _authProvider.checkIfUserIsLogged(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           Container(
            alignment: Alignment.center,
            child:  const Image(
             height: 100.0,
             width: 100.0,
             image: AssetImage('assets/images/logo_tayrona_solo.png'))),

             const Text("Tay-rona", style: TextStyle(
              fontFamily: 'Gilroy',
              color: negroLetras,
              fontSize: 24,
              fontWeight: FontWeight.w600
            )),
           ],
        ),
    );
  }
}
