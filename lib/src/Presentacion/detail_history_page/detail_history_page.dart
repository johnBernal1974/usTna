import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail_history_Controller/detail_history_controller.dart';

class DetailHistoryPage extends StatefulWidget {
  const DetailHistoryPage({super.key});

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  final DetailHistoryController _controller = DetailHistoryController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      backgroundColor: blancoCards,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: IconThemeData(color: negro, size: 24.r),
        title: Text(
          "Detalles del viaje",
          style: TextStyle(
            fontSize: 22.r,
            fontWeight: FontWeight.bold,
            color: negro,
          ),
        ),
        actions:  <Widget>[
          Image(
            height: 40.r,
            width: 100.r,
            image: const AssetImage('assets/images/logo_zafiro-pequeño.png'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildDriverInfo(),
            SizedBox(height: 15.r),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfilePhoto(),
        SizedBox(width: 25.r),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Conductor', style: TextStyle(fontSize: 14)),
            _buildName(),
            _buildSurname(),
            const SizedBox(height: 30),
            _buildTipovehiculo(),


          ],
        )
      ],
    );
  }

  Widget _buildProfilePhoto() {
    if (_controller.driver != null) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 15.r),
        child: CircleAvatar(
          backgroundColor: blanco,
          backgroundImage: _controller.driver!.image != null
              ? CachedNetworkImageProvider(_controller.driver!.image)
              : null,
          radius: 50,
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget _buildName() {
    return Container(
      alignment: Alignment.topLeft,
      child: headerText(
        text: _controller.driver?.the01Nombres ?? "",
        color: negro,
        fontSize: 18.r,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSurname() {
    return Container(
      alignment: Alignment.topLeft,
      child: headerText(
        text: _controller.driver?.the02Apellidos ?? "",
        color: negro,
        fontSize: 14.r,
        fontWeight: FontWeight.w800,
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
          fontSize: 12.r,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 5),
        headerText(
          text: _controller.driver?.the18Placa ?? '',
          color: negro,
          fontSize: 18.r,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerText(text: tipoVehiculo,color: negro,fontSize: 14,fontWeight: FontWeight.w700),
              _buildLicensePlate(),
            ],
          ),
          SizedBox(width: 30.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              obtenerTipoVehiculo()
            ],
          )
        ],
      ),
    );
  }

  Widget obtenerTipoVehiculo() {
    String tipoVehiculo = _controller.driver?.rol ?? "";
    if (tipoVehiculo == "carro") {
      return Image.asset("assets/images/carro_plateado.png", width: 80.r);
    } else if (tipoVehiculo == "moto") {
      return Image.asset("assets/images/moto_conductor.png", width: 40.r);
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
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 5.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color:primary,
                  fontSize: 14.r,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: TextStyle(
              color: negro,
              fontSize: 18.r,
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
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 5.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primary,
                  fontSize: 14.r,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: TextStyle(
              color: negro,
              fontSize: 14.r,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoFinal({required String title, required String content}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 5.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primary,
                  fontSize: 14.r,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            content,
            style: TextStyle(
              color: negro,
              fontSize: 14.r,
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
          padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 5.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                children: [
                  Text(
                    'Tarifa',
                    style: TextStyle(
                      color: primary,
                      fontSize: 14.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                formatter.format(_controller.travelHistory?.tarifa ?? 0),
                style: TextStyle(
                  color: negro,
                  fontSize: 14.r,
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
          padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Calificación',
                    style: TextStyle(
                      color: primary,
                      fontSize: 14.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              headerText(
                text: _controller.travelHistory?.calificacionAlConductor.toString() ?? '',
                color: negro,
                fontSize: 14.r,
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
