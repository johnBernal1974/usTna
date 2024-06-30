import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tayrona_usuario/src/Presentacion/take_foto_perfil/take_foto_perfil_controller/take_foto_perfil_controller.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';

class TakeFotoPerfil extends StatefulWidget {
  const TakeFotoPerfil({super.key});

  @override
  State<TakeFotoPerfil> createState() => _TakeFotoPerfilState();
}

class _TakeFotoPerfilState extends State<TakeFotoPerfil> {

  late TakeFotoController _controller = TakeFotoController();
  File? imageFile;
  final double _radiusWithoutImage = 60; // Radio del CircleAvatar cuando no hay imagen
  final double _radiusWithImage = 100;   // Radio del CircleAvatar cuando se ha seleccionado una imagen

  @override
  void initState() {
    super.initState();
    _controller = TakeFotoController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      _updateRadius();
    });
  }

  void _updateRadius() {
    setState(() {
      if (_controller.pickedFile != null) {
        _radiusWithoutImage;
        _radiusWithImage;
      }
    });
  }

  void refresh(){
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
            text: "Foto de perfil",
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
      // Aplicar un borde al CircleAvatar cuando no hay una imagen cargada
      decoration: _controller.pickedFile == null ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:primary, // Color del borde
          width: 1.0, // Ancho del borde
        ),
      ) : null,
      child: CircleAvatar(
        backgroundColor: blancoCards,
        radius: _controller.pickedFile != null ? _radiusWithImage : _radiusWithoutImage,
        child: ClipOval(
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
                    "assets/images/icono_persona.png",
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ), // Si hay una imagen cargada, no aplicar ningún borde
    );
  }

  Widget _botonTomarFoto() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: ElevatedButton(
        onPressed: () {
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
          _controller.guardarFotoPerfil();

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
      text: 'Por favor toma una selfie donde se pueda observar perfectamente toda tu cabeza y parte de los hombros. Verifica que no la tomes a contra luz.',
      fontSize: 14,
      color: negroLetras,
      fontWeight: FontWeight.w500
    );
  }
}
