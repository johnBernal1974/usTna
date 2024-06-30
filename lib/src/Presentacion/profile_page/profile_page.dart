import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tayrona_usuario/src/Presentacion/profile_page/profileController/profileController.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';
import 'package:cached_network_image/cached_network_image.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 24),
        title: const Text("Mis datos", style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: negro,
        )),
        actions: const <Widget>[
          Image(
              height: 40.0,
              width: 100.0,
              image: AssetImage('assets/images/logo_tayrona_solo.png'))

        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fotoPerfil(),
              _textSubtitledatosPersonales(),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 5),
              _nombres(),
              _apellidos(),
              _tipoDocumento(),
              _identificacion(),
              _email(),
              _celular(),

            ],
          ),
        ),

      ),
    );
  }

  Widget _fotoPerfil(){
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 15),
      child: CircleAvatar(
        backgroundColor: blanco,
        backgroundImage: _controller.client?.image != null
            ? CachedNetworkImageProvider(_controller.client!.image!)
            : null,
        radius: 80,
      ),
    );
  }
  Widget _nombres(){
    return Row(
      children: [
        headerText( text: 'Nombre:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the01Nombres ?? "", color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _apellidos(){
    return Row(
      children: [
        headerText( text: 'Apellidos:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the02Apellidos ?? "", color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tipoDocumento(){
    return Row(
      children: [
        headerText( text: 'Documento:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the03TipoDeDocumento ?? '', color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _identificacion(){
    return Row(
      children: [
        headerText( text: 'No. Identificación:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the04NumeroDocumento ?? '', color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _email(){
    return Row(
      children: [
        headerText( text: 'Email:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the06Email ?? '', color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }
  Widget _celular(){
    return Row(
      children: [
        headerText( text: 'Celular:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.client?.the07Celular ?? '', color: negroLetras,fontSize: 16,fontWeight: FontWeight.w700),
      ],
    );
  }

  void refresh(){
    setState(() {

    });
  }
}

Widget _textSubtitledatosPersonales(){
  return const Text('Datos personales', style: TextStyle(
    color: negro, fontSize: 20, fontWeight: FontWeight.w900
      ));
}

