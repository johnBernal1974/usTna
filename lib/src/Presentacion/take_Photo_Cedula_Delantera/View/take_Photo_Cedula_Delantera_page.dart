
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tayrona_usuario/src/Presentacion/take_Photo_Cedula_Delantera/take_Photo_Cedula_Delantera_controller/take_Photo_Cedula_Delantera_controller.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class TakePhotoCedulaDelanteraPage extends StatefulWidget {
  const TakePhotoCedulaDelanteraPage({super.key});

  @override
  State<TakePhotoCedulaDelanteraPage> createState() => _TakePhotoCedulaDelanteraPageState();
}

class _TakePhotoCedulaDelanteraPageState extends State<TakePhotoCedulaDelanteraPage> {

  late TakePhotoCedulaDelanteraController _controller = TakePhotoCedulaDelanteraController();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _controller = TakePhotoCedulaDelanteraController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }



  void refresh(){
    setState(() {

    });
  }// Radio del CircleAvatar cuando se ha seleccionado una imagen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
            text: "",
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: negro
        ),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 100.0,
              image: AssetImage('assets/images/logo_tayrona_solo.png'))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _textoTitulo(),
              _cajonFotoPerfil(),
              const SizedBox(height: 45),
              headerText(text: 'Indicaciones',fontSize: 18),
              _instruccionesFoto(),
              const SizedBox(height: 15,),
              _botonTomarFoto(),
              const SizedBox(height: 50),
              _ContinuarButton()
            ],
          ),
        ),
      ),

    );
  }

  Widget _cajonFotoPerfil() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(5),
      // Aplicar un borde al Container
      decoration: BoxDecoration(
        border: Border.all(
          color: gris, // Color del borde
          width: 1.0, // Ancho del borde
        ),
        borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
      ),
      child: Container(
        width: double.infinity, // Ancho del rectángulo
        height: 250, // Alto del rectángulo
        decoration: BoxDecoration(
          color: blancoCards,
          borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
          child: Stack(
            children: [
              if (_controller.pickedFile != null)
                Positioned.fill(
                  child: Image.file(
                    File(_controller.pickedFile!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              if (_controller.pickedFile == null || _controller.pickedFile?.name == 'asd')
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/documento_frente.png",
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _botonTomarFoto() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: ElevatedButton(
        onPressed: () {
          //_controller.getImageFromGallery();
          _controller.takePicture();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Color del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, color: blanco,), // Icono de cámara
            SizedBox(width: 8), // Espacio entre el icono y el texto
            Text(
              'Tomar Foto',
              style: TextStyle(fontSize: 20, color: blanco),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ContinuarButton() {
    // Verifica si se ha tomado y cargado una foto
    bool hasPhoto = _controller.pickedFile != null;
    return Visibility(
      visible: hasPhoto,
      child: ElevatedButton(
        onPressed: () {
          _controller.guardarFotoCedulaDelantera();
          //_controller.goToMapClient();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: azulOscuro, // Color del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continuar',
              style: TextStyle(fontSize: 20, color: blanco),
            ),
            SizedBox(width: 12), // Espacio entre el icono y el texto
            Icon(Icons.arrow_forward_ios_sharp, color: blanco,), // Icono de cámara
          ],
        ),
      ),
    );
  }

  Widget _instruccionesFoto(){
    return headerText(
        text: 'Por favor toma la foto de tu documento, sin flash y con el celular en posicion vertical',
        fontSize: 14,
        color: negroLetras,
        fontWeight: FontWeight.w500
    );
  }

  Widget _textoTitulo(){
    return headerText(
        text: 'Foto documento parte delantera',
        fontSize: 18,
        color: negroLetras,
        fontWeight: FontWeight.w700
    );
  }
}
