
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/Buttons/rounded_button.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import 'package:tayrona_usuario/src/Presentacion/SingUp_page/signUp_controller/signUp_controller.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SingUpPageState();
}


class _SingUpPageState extends State<SignUpPage> {
  String _dropdownValueTipoDocumento= "Cédula de Ciudadanía";
  final SignUpController _controller = SignUpController();
  final TextEditingController _date = TextEditingController();
  late FocusNode _nextFieldFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _controller.init(context);
      _nextFieldFocusNode = FocusNode();
    });
  }

  @override
  void dispose() {
    _nextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _controller.key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: primary, size: 30),
        title: headerText(
            text: "Registro",
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: primary),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 100.0,
              image: AssetImage('assets/images/logo_tayrona_solo.png'))

        ],

      ),
      body:
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 25.0, left: 40),
              child: headerText(
                  text: 'Ingresa tus datos',
                  color: negro,
                  fontSize: 18,
                  fontWeight: FontWeight.w700
              ),
            ),
            const SizedBox(height: 25),
            _nameImput(),
            _lastNameImput(),
            _tituloDocumento(),
            _tipoDocumento(),
            _identificationnumberImput(),
            _identificationExpeditionDate(),
            _celularNumberImput(),
            _emailImput(),
            _emailConfimImput(),
            _passwordImput(),
            _password2Imput(),


          Container(
              margin: const EdgeInsets.only(top: 45, left: 30, right: 30),
              child: Column(
                children: [
                  headerText(text: 'Al crear la cuenta en Tay-rona aceptas',
                      color: gris,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      headerText(text: 'nuestros',
                          color: gris,
                          fontSize: 14, fontWeight: FontWeight.w400),
                      GestureDetector(
                        onTap: () {},
                        child: headerText(text: '  Términos & Condiciones',
                            color: primary,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  headerText(text: 'Igualmente autorizas el uso y manejo de datos personales de acuerdo a la lay 1581/22',
                      color: gris,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ],
              ),
            ),


            Container(
              margin: const EdgeInsets.only(
                  top: 35, bottom: 60, left: 25, right: 25),
              child: createElevatedButton(context: context,
                  labelButton: 'Crear mi cuenta',
                  labelFontSize: 18,
                  color: primary,
                  icon: null,
                  func: () {
                    if (_controller != null && context != null) {
                      _controller.signUp();
                    } else {
                      print('Error: _controller o context es nulo');
                    }

                  }),
            ),
          ],
        ),
      ),
    );
  }

  void dropdownCallbackTipoDocumento(String? selectedValue)async {
    if(selectedValue is String){
      SharedPreferences sharepreferences = await SharedPreferences.getInstance();
      setState((){
        _dropdownValueTipoDocumento = selectedValue;
      });
      sharepreferences.setString('tipoDoc', _dropdownValueTipoDocumento);

    }
  }

  Widget _tituloDocumento(){
    return Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 10, left: 30),
        child: headerText(text: '* Tipo de documento', fontSize: 15, fontWeight: FontWeight.w400, color: primary));
  }

  Widget _tipoDocumento(){
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
              border: Border.all(color: grisMedio, width: 1),
              borderRadius: BorderRadius.circular(5),
          ),
          width: double.infinity,
          height: 65,
          margin: const EdgeInsets.only(left: 25, right: 25),
          child: DropdownButtonHideUnderline(
            child: DropdownButton< String>(
              value: _dropdownValueTipoDocumento,
              icon: const Icon(Icons.keyboard_arrow_down),
              iconSize: 25,
              isExpanded: true,
              iconEnabledColor: primary,
              style: const TextStyle(
                  color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Gilroy'),
              onChanged: dropdownCallbackTipoDocumento,
              items: const [
                DropdownMenuItem(value: "Cédula de Ciudadanía", child: Text("Cédula de Ciudadanía")),
                DropdownMenuItem(value: "Cédula de extranjería", child: Text("Cédula de extranjería")),
                DropdownMenuItem(value: "Pasaporte", child: Text("Pasaporte")),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nameImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.nombresController,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.text,
        cursorColor:turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline_rounded, size: 24, color: primary),
              Text('  Nombres', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _lastNameImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child:TextField(
        controller: _controller.apellidosController,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.text,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 24, color: primary),
              Text('  Apellidos', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _identificationnumberImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.numeroDocumentoController,
        style: const TextStyle(
            color: negroLetras, fontSize: 20, fontWeight: FontWeight.w800),
        keyboardType: TextInputType.text,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 24, color: primary),
              Text('  Número de identificación', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _identificationExpeditionDate() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _date,
        style: const TextStyle(
          color: negroLetras,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        keyboardType: TextInputType.text,
        cursorColor:turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.date_range, size: 20, color: primary),
              Text(
                '  Fecha de expedición',
                style: TextStyle(
                  color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          prefixIconColor: primary,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: grisMedio, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1940),
            lastDate: DateTime(2050),
          );

          if (pickedDate != null) {
            // Formatear la fecha seleccionada en formato deseado
            String formattedDate =
                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";

            // Establecer la fecha seleccionada en el controlador del campo de texto
            _date.text = formattedDate;
            SharedPreferences sharepreferences = await SharedPreferences.getInstance();
            sharepreferences.setString('fechaExpedicion', _date.text);
            print('Esta es la fecha seleccionada*********************** $_date');

            _nextFieldFocusNode.requestFocus();

          }
        },
        //focusNode: _expeditionDateFocusNode,
      ),
    );
  }

  Widget _celularNumberImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        focusNode: _nextFieldFocusNode,
        controller: _controller.celularController,
        style: const TextStyle(
            color: negroLetras, fontSize: 20, fontWeight: FontWeight.w800),
        keyboardType: TextInputType.phone,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_android_outlined,size: 24, color: primary),
              Text('  Número de celular', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _emailImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.emailController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.emailAddress,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 24, color: primary),
              Text('  Correo electrónico', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _emailConfimImput() {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.emailConfirmarController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.emailAddress,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read, size: 24, color: primary),
              Text('  Confirmar Correo', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _passwordImput (){
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.passwordController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 24, color: primary),
              Text('  Crea una Contraseña', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

  Widget _password2Imput (){
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
      child: TextField(
        controller: _controller.passwordConfirmarController,
        style: const TextStyle(
            color: negroLetras, fontSize: 17, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: turquesa,
        decoration: const InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_clock_sharp, size: 24, color: primary),
              Text('  Confirmar Contraseña', style: TextStyle(color: negroLetras,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),)
            ],
          ),
          prefixIconColor: primary,
          border:  OutlineInputBorder(),
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

