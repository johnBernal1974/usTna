import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail_history_Controller/detail_history_Controller.dart';

class DetailHistoryPage extends StatefulWidget {
  const DetailHistoryPage({Key? key}) : super(key: key);

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  final DetailHistoryController _controller = DetailHistoryController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 24),
        title: const Text(
          "Detalles del viaje",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: negro,
          ),
        ),
        actions: const <Widget>[
          Image(
            height: 40.0,
            width: 100.0,
            image: AssetImage('assets/images/logo_tayrona_solo.png'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDriverInfo(),
            const SizedBox(height: 15),
            _buildDivider(),
            _buildOrigin(),
            _buildDivider(),
            _buildDestination(),
            _buildDivider(),
            _inicioViaje(),
            _buildDivider(),
            _finalViaje(),
            _buildDivider(),
            _tarifa(),
            _buildDivider(),
            _calificacion(),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfilePhoto(),
        const SizedBox(width: 25),
        Column(
          children: [
            const Text('Conductor', style: TextStyle(fontSize: 11)),
            _buildName(),
            _buildSurname(),
            _buildTipovehiculo(),
            _buildLicensePlate()

          ],
        )
      ],
    );
  }

  Widget _buildProfilePhoto() {
    if (_controller.driver != null) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 15),
        child: CircleAvatar(
          backgroundColor: blanco,
          backgroundImage: _controller.driver!.image != null
              ? CachedNetworkImageProvider(_controller.driver!.image!)
              : null,
          radius: 50,
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget _buildName() {
    return Container(
      alignment: Alignment.topLeft,
      child: headerText(
        text: _controller.driver?.the01Nombres ?? "",
        color: negro,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSurname() {
    return Container(
      alignment: Alignment.topLeft,
      child: headerText(
        text: _controller.driver?.the02Apellidos ?? "",
        color: negroLetras,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildLicensePlate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        headerText(
          text: 'Placa:',
          color: negroLetras,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 5),
        headerText(
          text: _controller.driver?.the18Placa ?? '',
          color: negro,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _buildTipovehiculo() {
    String tipoVehiculo = "";
    String rol= _controller.driver?.rol ?? "";
    if(rol == "carro"){
      tipoVehiculo = "Vehículo";
    }else if(rol == "moto"){
      tipoVehiculo = "Motocicleta";
    }
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        children: [
          headerText(text: tipoVehiculo,color: negro,fontSize: 14,fontWeight: FontWeight.w700),
          obtenerTipoVehiculo()

        ],
      ),
    );
  }

  Widget obtenerTipoVehiculo() {
    String tipoVehiculo = _controller.driver?.rol ?? "";
    if (tipoVehiculo == "carro") {
      return Image.asset("assets/images/carro_azul.png", width: 60);
    } else if (tipoVehiculo == "moto") {
      return Image.asset("assets/images/moto_conductor.png", width: 40);
    } else {
      return Container(); // Devolver un widget vacío si no hay datos
    }
  }



  Widget _buildDivider() {
    return const Divider(height: 1, color: grisMedio);
  }

  Widget _buildOrigin() {
    return _buildLocationInfo(
      title: 'Origen:',
      content: _controller.travelHistory?.from ?? '',
    );
  }

  Widget _buildDestination() {
    return _buildLocationInfo(
      title: 'Destino:',
      content: _controller.travelHistory?.to ?? '',
    );
  }

  Widget _buildLocationInfo({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                color: negro,
                size: 12,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color:negro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: const TextStyle(
              color: gris,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  Widget _inicioViaje() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeInfoInicio(
          title: 'Inicio del Viaje',
          content: _controller.travelHistory?.inicioViaje ?? '',
        ),
      ],
    );
  }

  Widget _buildTimeInfoInicio({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: verdeCajon,
                size: 12,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: negro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: const TextStyle(
              color: gris,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoFinal({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: Colors.red,
                size: 12,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: negro,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: const TextStyle(
              color: gris,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _finalViaje() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeInfoFinal(
          title: 'Finalización del Viaje',
          content: _controller.travelHistory?.finalViaje ?? '',
        ),
      ],
    );
  }


  Widget _tarifa() {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '',
      decimalDigits: 0,
      name: '',
      customPattern: '\u00A4#,##0',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: Colors.blue,
                    size: 12,
                  ),
                  Text(
                    'Tarifa',
                    style: TextStyle(
                      color: negro,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                formatter.format(_controller.travelHistory?.tarifa ?? 0),
                style: const TextStyle(
                  color: negro,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calificacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 12,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Calificación',
                    style: TextStyle(
                      color: negro,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              headerText(
                text: _controller.travelHistory?.calificacionAlConductor.toString() ?? '',
                color: gris,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }
}
