
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/Buttons/rounded_button.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../login_controller/login_controller.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _controller.key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: primary, size: 30),
        title: headerText(
            text: "Login",
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: primary
        ),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 100.0,
              image: AssetImage('assets/images/logo_tayrona_solo.png'))

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 45, left: 30, right: 30, top: 45),
              child: headerText(
                  text: "Ingresa tu correo y contraseña\npara iniciar sesión",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: negroLetras),
            ),

            Container(
              margin: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: [
                  _emailImput(),
                  _passwordImput(),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 30,left: 25, right: 25),
              child: createElevatedButton(context: context,
                  labelButton: 'Ingresar',
                  labelFontSize: 20,
                  color: primary,
                  icon: null,
                  func: () {
                    _controller.login();
                  }),
            ),

            Center(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 35.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'forgot_password');
                      },
                      child: const Text(
                          '¿Olvidaste tu contraseña?', style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.0
                      )),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'sign_up');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 25.0, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                              '¿No tienes una cuenta?', style: TextStyle(
                              color: negroLetras,
                              fontWeight: FontWeight.w400,
                              fontSize: 15.0
                          )),
                          GestureDetector(
                            onTap: () {
                              _controller.goToRegisterPage();
                            },
                            child: const Text(
                                '  Registrarse aquí', style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            ),
          ],
        ),
      ),
      );
  }

  Widget _emailImput() {
    return TextField(
      controller: _controller.emailController,
      style: const TextStyle(
          color: negroLetras, fontSize: 16, fontWeight: FontWeight.w700),
      keyboardType: TextInputType.emailAddress,
      cursorColor: const Color.fromARGB(255, 5, 158, 187),
      decoration: const InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, size: 20, color: primary),
            Text('  Correo electrónico', style: TextStyle(color: primary,
                fontSize: 17,
                fontWeight: FontWeight.w400))
          ],
        ),
        prefixIconColor: primary,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: grisMedio, width: 1)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 2)
        ),
      ),

    );
  }


  Widget _passwordImput() {
    return Container(
      margin: const EdgeInsets.only(top: 35),
      child: TextField(
        controller: _controller.passwordController,
        obscureText: true,
        style: const TextStyle(
            color: negroLetras, fontSize: 15, fontWeight: FontWeight.w500),
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color.fromARGB(255, 5, 158, 187),
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_clock_sharp, size: 20, color: primary),
              Text('  Contraseña', style: TextStyle(color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w400),)
            ],
          ),
          prefixIconColor: primary,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grisMedio, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primary, width: 2)
          ),
        ),

      ),
    );
  }
}
